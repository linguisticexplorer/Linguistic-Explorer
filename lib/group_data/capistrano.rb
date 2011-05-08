module GroupData

  # Capistrano task for uploading via csc.
  #
  # Just add "require 'group_data/capistrano'" in your Capistrano deploy.rb

  # run("cd #{deploy_to}/current && /usr/bin/env rake `<task_name>` RAILS_ENV=production")`
  # cap -a show_options -s opt1=value1

  Capistrano::Configuration.instance.load do

    namespace :group_data do

      usage = "Usage: cap group_data:upload -s conf=/path/to/config.yml"

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
          YAML.load_file("/Users/ross/dev/linguistic-explorer/spec/csv/import.yml")
        rescue
          puts <<-MSG
Error: No configuration file specified.

#{usage}
          MSG
        end

        remote_dir    = "/var/tmp/#{Time.now.to_i}"
        remote_config = "#{remote_dir}/config.yml"

        run "mkdir #{remote_dir}"

        remote_yml = {}.tap do |yml|
          local_yml.each do |path_key, path|
            yml[path_key] = path.gsub(/.*\//, "#{remote_dir}/#{$1}")
          end
        end

        puts remote_yml
        puts local_yml

        begin
          remote_yml.each do |path_key, remote_path|
            upload local_yml[path_key], remote_path
          end

          File.open("import.yml", "wb+") { |f| f.write remote_yml }
          upload "import.yml", remote_config
        ensure
          File.unlink("import.yml")
        end

        run("cd #{deploy_to}/current && /usr/bin/env rake group_data:import RAILS_ENV=production CONFIG=#{remote_config}")
      end
    end
  end

end
