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
      # Take care of reseting minor and patch entries when bumping...
      case fieldname
      when 'major'
        current['major'] = "#{Integer(current[fieldname]) + 1}"
        current['minor'] = '0';
        current['patch'] = '0';
      when 'minor'
        current['minor'] = "#{Integer(current[fieldname]) + 1}"
        current['patch'] = '0';
      else
        current[fieldname] = "#{Integer(current[fieldname]) + 1}"
      end

	    File.open(TARGET, 'w') { |f| YAML.dump(current, f) }
	    puts "New Version set to: #{current['major'] + "." + current['minor'] + "." + current['patch'] + '-' + current['build']}"
	  end

end
