module GroupData

  # Capistrano task for uploading via csc.
  #
  # Just add "require 'group_data/capistrano'" in your Capistrano deploy.rb

  # run("cd #{deploy_to}/current && /usr/bin/env rake `<task_name>` RAILS_ENV=production")`
  # cap -a show_options -s opt1=value1

  Capistrano::Configuration.instance.load do

    namespace :group_data do

      desc "Download sql dump file from production"
      task :dump do
        remote_file = "/var/backups/database/terraling_production.sql"
        local_file  = ENV['DEST'] || "./terraling_production.sql"
        download remote_file, local_file
      end

      usage = "Usage: cap group_data:upload\n\ncap group_data:upload -s conf=/path/to/config.yml"
      desc <<-DESC
        Upload csv files into production database from specified yaml file.

        By default, if no config file is specified with -s config or c options \
        then the script will not proceeed.

        Usage: #{usage}

          # /Users/ross/dev/linguistic-explorer/spec/csv/import.yml
      DESC
      task :import do
        require 'yaml'

        local_yml = begin
          local_config = defined?(conf) ? conf : "config/import.yml"
          YAML.load_file(local_config)
        rescue
          puts <<-MSG
Error: No configuration file specified.

#{usage}
          MSG
        end


        # Translate local config into remote config
        remote_dir    = "/var/tmp/#{Time.now.to_i}"
        config_name   = "config.yml"
        remote_config = "#{remote_dir}/#{config_name}"

        remote_yml = {}.tap do |yml|
          local_yml.each do |path_key, path|
            yml[path_key] = path.gsub(/.*\//, "#{remote_dir}/#{$1}")
          end
        end

        puts remote_yml
        puts local_yml

        # Upload local config and csvs to remote server
        begin
          run "mkdir #{remote_dir}"
          remote_yml.each do |path_key, remote_path|
            upload local_yml[path_key], remote_path
          end

          File.open(config_name, "wb+") { |f| f.write remote_yml.to_yaml }
          upload config_name, remote_config
        ensure
          File.unlink config_name if File.exists? config_name
        end

        cmd = ["cd #{deploy_to}/current"]
        cmd << "/usr/bin/env rake group_data:import RAILS_ENV=production CONFIG=#{remote_config}"
        cmd = cmd.join(' && ')


        run cmd
        puts "Importing data..."
      end
    end
  end

end
