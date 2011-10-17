namespace :group_data do
  usage = "Usage: rake group_data:import CONFIG=/path/to/config.yml"

  desc <<-DESC
    Imports data in .csv files specified in configuration yml
    #{usage}
  DESC
  task :import => :environment do
    raise "Must specify a config file.\n\n#{usage}" unless ENV['CONFIG'].present?

    config    = YAML.load_file(ENV['CONFIG'])

    GroupData::Importer.import(config)
  end

  usage = "Usage: rake group_data:validate CONFIG=/path/to/config.yml"

  desc <<-DESC
    Validate data in .csv files specified in configuration yml
    #{usage}
  DESC
  task :validate => :environment do
    raise "Must specify a config file.\n\n#{usage}" unless ENV['CONFIG'].present?

    config    = YAML.load_file(ENV['CONFIG'])

    GroupData::Validator.load(config).validate!
  end

end