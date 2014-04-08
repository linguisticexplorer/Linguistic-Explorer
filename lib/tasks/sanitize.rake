namespace :sswl do

  usage = "Usage: rake sswl:sanitize CONFIG=/path/to/config.yml"

  desc <<-DESC
    Sanitize SSWL description field for the property.csv file in order to import it in Terraling
    #{usage}
  DESC
  task :sanitize => :environment do
    raise "Must specify a config file.\n\n#{usage}" unless ENV['CONFIG'].present?

    config    = YAML.load_file(ENV['CONFIG'])

    file = config[:property]
    strings = {
        "\"" => "[]",
        ";"  => "{}",
        "(\n|\r)*" => "",
        "@@@" => "@@@\n"
    }

    strings.each do |bad, fixed|
      text = File.read(file){|f| f.readline }
      new_text = text.gsub(/#{bad}/, fixed)
      File.open(file, "w") {|file| file.puts new_text}
    end
  end

end