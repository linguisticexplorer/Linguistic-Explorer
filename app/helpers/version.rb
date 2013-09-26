require 'yaml'

module Version

	  TARGET = Rails.root.join("VERSION.yml")

	  def self.get()
	  	current = YAML.load_file(TARGET)
      current['major'] + "." + current['minor'] + "." + current['patch'] + '-' + current['build']
	  end

	  VERSION = self.get

	  def self.set(major, minor, patch, build)
	  	current = YAML.load_file(TARGET)
      current['major'] = major unless major.nil?
      current['minor'] = minor unless minor.nil?
      current['patch'] = patch unless patch.nil?
      current['build'] = build unless build.nil?
      # Write new version now
      File.open(TARGET, 'w') { |f| YAML.dump(current, f) }
	  end

	  def self.bump(fieldname)
	  	
	  	current = YAML.load_file(TARGET)
	  	puts "Incrementing #{fieldname} value from #{Integer(current[fieldname])} to #{Integer(current[fieldname]) + 1}" unless fieldname.nil?
      current[fieldname] = "#{Integer(current[fieldname]) + 1}" unless fieldname.nil?

	    File.open(TARGET, 'w') { |f| YAML.dump(current, f) }
	    puts "New Version set to: #{current['major'] + "." + current['minor'] + "." + current['patch'] + '-' + current['build']}"
	  end

end
