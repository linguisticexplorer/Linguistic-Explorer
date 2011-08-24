module GroupData

  # Capistrano task for uploading via csc.
  #
  # Just add "require 'group_data/capistrano'" in your Capistrano deploy.rb

  # run("cd #{deploy_to}/current && /usr/bin/env rake `<task_name>` RAILS_ENV=production")`
  # cap -a show_options -s opt1=value1

  #noinspection RubyArgCount
  Capistrano::Configuration.instance.load do

    namespace :group_data do
      
      desc "Download sql dump file from production"
      task :dump do
        remote_file = "/var/backups/database/terraling_production.sql"
        local_file  = ENV['DEST'] || "./terraling_production.sql"
        download remote_file, local_file
      end

      usage = "Usage:\tcap group_data:upload\n\n\t\tcap group_data:upload -s conf=/path/to/config.yml"
      desc <<-DESC
        Upload csv files into production database from specified yaml file.

        By default, if no config file is specified with -s config or c options \
        then the script will not proceeed.

        Usage: #{usage}

          # /Users/ross/dev/linguistic-explorer/spec/csv/import.yml
      DESC
      task :import do
        require 'yaml'
        
        okString = "OK"
        errString = "ERROR"
        defaultConfig = "config/import.yml"
        err = 0
        
        # Use exists? instead of defined? -> Capistrano Doc
        if exists?(:conf)
          puts "Custom configuration file:\n\t\e[34m#{conf}\e[0m"
          local_config ||= conf
        else
          puts "Using default configuration file:\n\t\e[34m#{defaultConfig}\e[0m"
          local_config ||= defaultConfig
        end
        
        local_yml = begin
          print "Reading configuration file..."
          #local_config = "config/import.yml"
          local_config = defaultConfig if err==1
          YAML.load_file(local_config)
        rescue Errno::ENOENT
          print "\e[31m#{errString}\n\e[0m"
          puts <<-MSG
\tError: Configuration file not found => #{local_config}
          
\t#{usage}
            
\tWill use default configuration file: \e[34m./#{defaultConfig}\e[0m
          MSG
          err += 1
          retry if err <2
          puts
          exit
        rescue
          print "\e[31mERROR\n\e[0m"
          puts <<-MSG
\tError: Problem loading the configuration file => #{local_config}

\t#{usage}

\tExiting the task
          MSG
          exit
        end
        err = 0
        # Config file found
        print "\e[32m#{okString}\n\e[0m"

        print "Check data files..."
        ok = true
        local_yml.each do |path_key, path|
           ok &= File.exists? path
          if(!ok)
          print "\e[31mERROR\n\e[0m"
          puts <<-MSG
\tError: CSV file does not exist: \n\t#{path_key} => \e[34m#{path}\e[0m

\tExiting the task
          MSG
          exit
        end
        end

        print "\e[32m#{okString}\n\e[0m"
        # Translate local config into remote config
        remote_dir    = "/var/tmp/#{Time.now.to_i}"
        config_name   = "config.yml"
        remote_config = "#{remote_dir}/#{config_name}"
        
        puts "Temporary remote configuration will placed at:\n\t '\e[34m#{remote_config}\e[0m'\n"

        remote_yml = {}.tap do |yml|
          local_yml.each do |path_key, path|
            yml[path_key] = path.gsub(/.*\//, "#{remote_dir}/#{$1}")
          end
        end

        #puts remote_yml
        puts
        #puts local_yml
        
        # Upload local config and csvs to remote server
        begin
          run "mkdir #{remote_dir}"

          #|channel, name, sent, total|
          remote_yml.each do |path_key, remote_path|
            upload local_yml[path_key], remote_path
          end
          print "Uploading CSVs to remote path..."
          print "\e[32m#{okString}\n\e[0m"

          File.open(config_name, "wb+") { |f| f.write remote_yml.to_yaml }
          upload config_name, remote_config

          print "Uploading Configuration file..."
          print "\e[32m#{okString}\n\e[0m"
        ensure
          File.unlink config_name if File.exists? config_name
        end

        #cmd = ["cd #{deploy_to}/current"]

        # For debug in localhost purpose
        cmd = ["cd #{deploy_to}"]
        cmd << "export DYLD_LIBRARY_PATH=/usr/local/mysql/lib/"
        cmd << "/usr/bin/env rake group_data:import RAILS_ENV=development CONFIG=#{remote_config} --trace"
        cmd = cmd.join(' && ')


        run cmd
        puts "Importing data...Done"
      end
    end
  end

end
