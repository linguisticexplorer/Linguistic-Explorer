namespace :sswl do

  usage = "Usage: rake sswl:convert CONVERT_CONFIG=/path/to/config.yml"

  desc <<-DESC
    Convert SSWL .csvs to Terraling data
    #{usage}
  DESC
  task :convert => :environment do
    raise "Must specify a config file.\n\n#{usage}" unless ENV['CONVERT_CONFIG'].present?

    config    = YAML.load_file(ENV['CONVERT_CONFIG'])

    invoke_converter config
  end

  usage = "Usage: rake sswl:dump DUMP_CONFIG=/path/to/config.yml"

  desc <<-DESC
    Dump in csv files SSWL data from the server
    #{usage}
  DESC
  task :dump => :environment do
    raise "Must specify a config file.\n\n#{usage}" unless ENV['DUMP_CONFIG'].present?

    config    = YAML.load_file(ENV['DUMP_CONFIG'])

    tables = {
        users: ["id", "first_name", "last_name", "email", "user_type", "role", "language"],
        languages: ["id", "value", "property", "language"],
        example_objects: ["id", "language"],
        examples: ["id", "language", "value", "property", "example_object_id"],
        properties: ["id", "property"] #, "description"]
    }

    dumpDir = "/dumpdir/csvdump/"

    param_query = "SELECT 1 UNION (SELECT 2 INTO OUTFILE '3' FIELDS TERMINATED BY ';' LINES TERMINATED BY 'END\\\\n' FROM 4 ORDER BY 'id' DESC);"

    queries = {}.tap do |query|
      tables.each do |table, cols|
        query[table] = param_query.gsub(/1/, "\'#{cols.join('\', \'')}\'").gsub(/2/, "#{cols.join(', ')}").gsub(/3/, "#{dumpDir}#{table.to_s}.csv").
            gsub(/4/, "#{table.to_s}")
      end
    end

    mySqlCommand = "mysql -u#{config["dbuser"]} -p#{config["dbpassword"]} #{config["db"]} -e"

    commands = []

    queries.each do |table, query|
      commands << "#{mySqlCommand} \"#{query}\""
    end


    # connect to SSWL via ssh
    Net::SSH.start(config["host"], config["username"], :password => "#{config["password"]}") do |ssh|
      puts "Connected to #{config["host"]}"
      commands.each do |command|
        puts command
        puts ssh.exec!(command)
      end
      ssh.loop
    end

    localPath = config["localPath"]
    FileUtils.mkdir_p localPath

    # copy file to localhost
    puts "Copying file to localhost..."
    Net::SCP.start(config["host"], config["username"], :password => "#{config["password"]}") do |scp|
      tables.keys.each { |file| scp.download! "#{dumpDir}#{file.to_s}.csv", "#{localPath}#{file.to_s}.csv" }
    end

    cleanCommands = []
    cleanCommands << "rm -f /dumpdir/csvdump/*.csv"

    # clean directory
    Net::SSH.start(config["host"], config["username"], :password => "#{config["password"]}") do |ssh|
      puts "Clean directory..."
      cleanCommands.each do |command|
        puts ssh.exec!(command)
      end
      ssh.loop
    end

    paths = {}
    # rename file in localhost
    tables.keys.each do |file|
      new_name = "#{localPath}#{file.to_s}.csv"

      #cache paths
      if file =~ /languages/
        paths[:ling] = "#{new_name}"
        paths[:lings_property] = "#{new_name}"
      end
      if file =~ /examples/
        paths[:stored_value] = "#{new_name}"
        paths[:examples_lings_property] = "#{new_name}"
      end
      paths[:user] = "#{new_name}" if file =~ /users/
      paths[:example] = "#{new_name}" if file =~ /example_objects/
      paths[:property] = "#{new_name}" if file =~ /properties/
    end

    puts "Creating converter config file..."
    # create YAML file for import
    File.open("#{localPath}convert.yml", "wb") { |f| f.write paths.to_yaml }

  end

  usage = "Usage: rake sswl:migrateToTerraling DUMP_CONFIG=/path/to/config.yml"

  desc <<-DESC
    Dump and convert SSWL data to Terraling data
    #{usage}
  DESC
  task :migrateToTerraling => :environment do
    raise "Must specify a config file.\n\n#{usage}" unless ENV['DUMP_CONFIG'].present?

    Rake::Task["sswl:dump"].invoke

    config = YAML.load_file(ENV['DUMP_CONFIG'])

    localPath = config["localPath"]

    config = YAML.load_file("#{localPath}convert.yml")

    invoke_converter config
    puts "Data has been converted in Terraling format and stored in:"
    puts "\t#{localPath}terraling/"
    puts "Completed"
  end

  def invoke_converter(config)
    SswlData::Converter.load(config).convert!
  end

end