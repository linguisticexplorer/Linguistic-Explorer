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

      usage = "Usage:\tcap group_data:import\n\n\t\tcap group_data:import -s conf=/path/to/config.yml"
      desc <<-DESC
        Upload csv files into production database from specified yaml file.

        By default, if no config file is specified with -s config or c options \
        then the script will not proceed.

        Usage: #{usage}

          # /Users/ross/dev/linguistic-explorer/spec/csv/import.yml
      DESC
      task :import do
        require 'yaml'
        require 'group_data/validator'

        okString = "OK"
        errString = "ERROR"
        defaultConfig = "config/import.yml"
        err = 0

        # Use exists? instead of defined? -> Capistrano Doc
        if exists?(:conf)
          puts "Custom configuration file:\n\t#{blue conf}"
          local_config ||= conf
        else
          puts "Using default configuration file:\n\t#{blue defaultConfig}"
          local_config ||= defaultConfig
        end


        # Load configuration file, if it doesn't find specified path
        # will make a try to load default configuration file
        local_yml = begin
          print "Reading configuration file..."
          #local_config = "config/import.yml"
          local_config = defaultConfig if err==1
          YAML.load_file(local_config)
        rescue Errno::ENOENT
          print "#{red errString}\n"
          puts <<-MSG
          \tError: Configuration file not found => #{local_config}
          
          \t#{usage}
            
          \tWill use default configuration file: #{blue defaultConfig}
          MSG
          err += 1
          retry if err <2
          puts
          exit_with_error
        rescue
          print "#{red "ERROR"}\n"
          puts <<-MSG
          \tError: Problem loading the configuration file => #{local_config}

          \t#{usage}

          \tExiting the task
          MSG
          exit_with_error
        end
        err = 0
        # Config file found
        print "#{green okString}\n"


        # Check that files are in path
        print "Check files..."
        ok = true
        local_yml.each do |path_key, path|
          ok &= File.exists? path
          if(!ok)
            print "#{red "ERROR"}\n"
            puts <<-MSG
            \tError: CSV file does not exist: \n\t#{path_key} => #{blue path}

            \tExiting the task
            MSG
            exit_with_error
          end
        end

        print "#{green okString}\n"

        # Validate data in files with a local Rake task before send to the remote server
        puts "Check data files..."
        system "rake group_data:validate CONFIG=#{local_config}"
        exit_if_rake_error                                      # Will exit if rake task exit with an error
        puts "Check data files...#{green okString}\n"

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
          print "#{green okString}\n"

          File.open(config_name, "wb+") { |f| f.write remote_yml.to_yaml }
          upload config_name, remote_config

          print "Uploading Configuration file..."
          print "#{green okString}\n"
        ensure
          File.unlink config_name if File.exists? config_name
        end

        cmd = ["cd #{deploy_to}/current"]

        # Sometimes it is useful for testing in localhost...
        #cmd << "export DYLD_LIBRARY_PATH=/usr/local/mysql/lib/"

        cmd << "/usr/bin/env bundle exec rake group_data:import RAILS_ENV=production CONFIG=#{remote_config}"
        cmd = cmd.join(' && ')

        run cmd
        puts "Importing data...Done"
      end

      def blue(text)
          return "\e[34m#{text}\e[0m"
      end

      def green(text)
          return "\e[32m#{text}\e[0m"
      end

      def red(text)
          "\e[31m#{text}\e[0m"
      end

      def exit_if_rake_error()
        exit_with_error if $? != 0
      end

      def exit_with_error()
        exit(1)
      end

    end

  end
end