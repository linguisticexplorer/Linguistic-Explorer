# SswlData::Converter
#
#
require 'csv'

module SswlData
  class Converter

    class << self
      def load(config)
        validator = new(config)
        validator
      end
    end

    attr_accessor :config

    def self.lazy_init_cache(*caches)
      caches.each do |cache|
        define_method("#{cache}") do
          instance_variable_get("@#{cache}") ||
              (instance_variable_set("@#{cache}", {}) && instance_variable_get("@#{cache}"))
        end
      end
    end

    ##puts "Loading lazy_cache"
    lazy_init_cache :user_ids, :ling_ids, :property_ids, :example_ids, :lings_property_ids,
                    :examples_lings_property_ids, :stored_value_ids, :member_ids

    # accepts path to yaml file containing paths to csvs
    def initialize(config)
      @config = config
      @config.symbolize_keys!
      @sanitized = {}
      @headers = load_headers
    end

    def convert!

      reset = "\r\e[0K"
      start = Time.now

      print "converting users..."

      # SSWL
      #
      # ===> Users.csv <============
      # id, first_name, last_name, username, hashed_password, affiliation, user_type, email, website, role, language, salt
      #
      # Terraling
      #
      # ==> User.csv <==
      # id,name,email,access_level,password
      user_ids = {}
      csv_for_each :user do |row|

        Converter.convert_user_in(row, user_ids)
      end

      write_csv :user, user_ids

      print "#{reset}converting users...[OK]"

      print "\nconverting groups..."

      # Terraling
      #
      # ==> Group.csv <==
      # id, name, privacy, depth_maximum, ling0_name, ling1_name, property_name, category_name, lings_property_name, example_name, examples_lings_property_name, example_fields

      CSV.open(new_path_for_csv(:group), "wb") do |csv|
        csv << @headers[:group]
        time = Time.new
        name = "SSWL_Data"
        csv << ["0",name,"public","0","Language","not-present","Property",
                "Category","Value","Example","Example Value","gloss, words, translation, comment"]

      end

      print "#{reset}converting groups...[OK]"

      print "\nconverting memberships..."

      # SSWL
      #
      # ==> Users.csv <==
      # id, first_name, last_name, username, hashed_password, affiliation, user_type, email, website, role, language, salt
      #
      # Terraling
      #
      # ==> Membership.csv <==
      # id,member_id,group_id,level,creator_id
      member_ids = {}
      csv_for_each :user do |row|

        # cache member id
        Converter.convert_membership_in(row, member_ids)
      end

      write_csv :membership, member_ids

      print "#{reset}converting memberships...[OK]"

      print "\nconverting lings..."

      # SSWL
      #
      # ===> Languages.csv <=====
      # id, value, property, language
      #
      # Terraling
      #
      # ==> Ling.csv <==
      # id,name,parent_id,depth,group_id,creator_id
      ling_ids = {}
      csv_for_each :ling do |row|

        # cache ling id
        Converter.convert_ling_in(row, ling_ids)

      end

      write_csv :ling, ling_ids

      print "#{reset}converting lings...[OK]"

      print "\nconverting categories..."

      # Terraling
      #
      # ==> Category.csv <==
      # id,name,depth,group_id,creator_id,description
      CSV.open(new_path_for_csv(:category), "wb") do |csv|
        csv << @headers[:category]
        csv << [ "0","Category 0","0","0","Category created from SSWL Migration",nil ]

      end

      print "#{reset}converting categories...[OK]"

      print "\nconverting examples..."

      # SSWL
      #
      # ===> ExampleObjects.csv <===
      # id, language, sentence_number
      #
      # Terraling
      # ==> Example.csv <==
      # id,name,ling_id,group_id,creator_id
      #
      counter = 0
      example_ids = {}
      csv_for_each :example do |row|

        next if ling_ids["#{Converter.decode(row["language"])}"].nil?

        # cache example id
        counter = Converter.convert_example_in(row, example_ids, ling_ids, counter)
      end

      write_csv :example, example_ids

      print "#{reset}converting examples...[OK]"

      print "\nconverting properties..."

      #sanitize_text_in_fields :property
      # SSWL
      # ===> Properties.csv <====
      # id, property, description
      #
      # Terraling
      # ==> Property.csv <==
      # id,name,description,category_id,group_id,creator_id
      max_id = 0
      property_ids = {}
      csv_for_each :property do |row|
        max_id = Converter.convert_property_in(row, property_ids, max_id)

      end

      print "#{reset}converting properties...[OK]"

      print "\nconverting lings_property..."

      # SSWL
      #
      # ===> Languages.csv <=====
      # id, value, property, language
      #
      # Terraling
      #
      # ==> LingsProperty.csv <==
      # id,ling_id,property_id,value,group_id,creator_id
      #
      lings_property_ids = {}
      csv_for_each :lings_property do |row|

        max_id = Converter.update_property_in(row, property_ids, max_id)

        Converter.convert_ling_prop_in(row, lings_property_ids, ling_ids, property_ids )
      end

      write_csv :property, property_ids

      write_csv :lings_property, lings_property_ids

      print "#{reset}converting lings_property...[OK]"

      # SSWL
      #
      # ===> Examples.csv <==========
      # id, language, value, sentencenumber, property, example_object_id
      #
      # Terraling
      #
      # ==> ExampleLingsProperty.csv <===
      # id,example_id,lings_property_id,group_id,creator_id
      #
      print "\nconverting examples_lings_property..."

      cache_properties = {}

      csv_for_each :examples_lings_property do |row|

        next if property_ids[row["property"]].nil?
        # Check if the row is the referrer to the property
        # and cache it
        cache_properties[row["example_object_id"]] ||= {
            "lang" => "#{Converter.decode(row["language"])}",
            "value" => row["value"],
            "name" => row["property"]
        }

      end

      csv_for_each :examples_lings_property do |row|
        next unless property_ids[row["property"]].nil?

        # Retrieve from cache to build reference
        property = cache_properties[row["example_object_id"]]
        property.nil? ? next : lings_prop_entry = lings_property_ids["#{property["lang"]}:#{property["name"]}:#{property["value"]}"]

        if lings_prop_entry.nil?
          show_error property
          next
        end

        lings_prop_id = lings_prop_entry["id"]

        # cache examples_lings_property id
        examples_lings_property_ids[row["example_object_id"]] ||= {
            "id" => "#{row["id"]}",
            "value" => "#{row["value"]}",
            "group_id" => "0",
            "example_id" => "#{row["example_object_id"]}",
            "lings_property_id" => "#{lings_prop_id}",
            "ling_id" => "#{ling_ids[Converter.decode(row["language"])]["id"]}"
        }
      end

      write_csv :examples_lings_property, examples_lings_property_ids

      print "#{reset}converting examples_lings_property...[OK]"

      # SSWL
      #
      # ===> Examples.csv <==========
      # id, language, value, sentencenumber, property, example_object_id
      #
      # Terraling
      #
      # ===> StoredValue.csv <=====
      # id, storable_id, storable_type, key, value, group_id
      #
      print "\nconverting stored_values..."
      stored_value_ids = {}
      csv_for_each :stored_value do |row|
        next unless property_ids[row["property"]].nil?

        Converter.convert_stored_value_in(row, stored_value_ids)
      end

      write_csv :stored_value, stored_value_ids

      print "#{reset}converting stored_values...[OK]"

      print "\nCreating YAML configuration file for importing..."

      config = {}.tap do |paths|
        @headers.keys.each do |model|
          paths[model.to_s] = new_path_for_csv(model)
        end
      end
      File.open(get_yaml_path, "wb") { |f| f.write config.to_yaml }

      print "#{reset}Creating YAML configuration file for importing...[OK]\n"

      elapsed = seconds_fraction_to_time(Time.now - start)
      puts "Time for converting: #{elapsed[0]} : #{elapsed[1]} : #{elapsed[2]}"
    end

    def self.convert_stored_value_in(row, stored_value_ids)
      stored_value_ids[row["id"]] ||={
          "id" => "#{row["id"]}",
          "key" => "#{row["property"]}",
          "value" => "#{row["property"]}:#{row["value"]}",
          "group_id" => "0",
          "storable_type" => "Example",
          "storable_id" => "#{row["example_object_id"]}"
      }
    end

    def self.convert_ling_prop_in(row, lings_property_ids, ling_ids, property_ids)
      lings_prop_id = "#{decode(row["language"])}:#{property_ids[row["property"]]["name"]}:#{row["value"]}"

      # cache lings_property id
      lings_property_ids[lings_prop_id] ||= {
          "id" => "#{row["id"]}",
          "value" => "#{row["value"]}",
          "group_id" => "0",
          "category_id" => "0",
          "property_id" => "#{property_ids[row["property"]]["id"]}",
          "ling_id" => "#{ling_ids[decode(row["language"])]["id"]}"
      }
    end

    def self.update_property_in(row, property_ids, max_id)
      max_id +=1 if property_ids[row["property"]].nil?

      # Some properties are splitted in more files
      property_ids[row["property"]] ||= {
          "id" => "#{max_id}",
          "name" => "#{row["property"]}",
          "group_id" => "0",
          "category_id" => "0"
      }
      max_id
    end

    def self.convert_property_in(row, property_ids, max_id)
      max_id = row["id"].to_i unless max_id > row["id"].to_i

      description = "\"#{row["description"]}\""

      # cache property id
      property_ids[row["property"]] ||= {
          "id" => "#{row["id"]}",
          "name" => "#{row["property"]}",
          "group_id" => "0",
          "category_id" => "0",
          "description" => description
      }
      max_id
    end

    def self.convert_example_in(row, example_ids, ling_ids, counter)
      if ling_ids["#{decode(row["language"])}"].present?
        example_ids[row["id"]] ||= {
            "id" => "#{row["id"]}",
            "name" => "Example_#{counter}",
            "group_id" => "0",
            "ling_id" => "#{ling_ids["#{decode(row["language"])}"]["id"]}"
        }
        counter+=1
      end
    end

    def self.convert_ling_in(row, ling_ids)
      ling_ids[decode(row["language"])] ||= {
          "id" => "#{row["id"]}",
          "name" => "#{decode(row["language"])}",
          "group_id" => "0",
          "depth" => "0"
      }
    end

    #TODO: improve converting handling Language Experts and Property Author
    def self.convert_membership_in(row, member_ids)
      member_ids[row["id"]] ||= {
          "id" => "#{row["id"]}",
          "member_id" => "#{row["id"]}",
          "group_id" => "0",
          "level" => row["user_type"] == "admin" ? "admin" : "member"
      }
    end

    def self.convert_user_in(row, user_ids)
      # Generator of a random password
      char_array = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten;
      password = (0..8).map { char_array[rand(char_array.length)] }.join;

      first_name = row["first_name"]
      first_name = first_name.gsub(/\s/, '') if first_name =~ /\s/
      last_name = row["last_name"]
      last_name = last_name.gsub(/\s/, '') if last_name =~ /\s/
      email = row["email"].present? ? row["email"] : "#{first_name}@#{last_name}.com"
      # cache user id
      user_ids[row["id"]] = {
          "id" => "#{row["id"]}",
          "name" => "#{row["first_name"]} #{row["last_name"]}",
          "email" => "#{email}",
          "access_level" => row["user_type"] == "admin" ? "admin" : "user",
          "password" => password
      }
    end

    private

    # Change from double-quotes in descriptions
    # writing single quote to sanitize csv for parser
    def sanitize_csv(key)
      if !@sanitized[key]
        file = @config[key]
        strings = {
            "\"" => "\\\\'",
            "\\\\;" => "\.",
            "END" => "\n"
        }
        @sanitized[key] ||= true
        strings.each do |bad, fixed|
          text = File.read(file){|f| f.readline }
          new_text = text.gsub(/#{bad}/, fixed)
          File.open(file, "w") {|file| file.puts new_text}
        end
        
      end
    end

    def self.decode(string)
      string #.nil? ? string : Iconv.new('UTF-8','LATIN1').iconv(string.encode("cp1252").force_encoding("UTF-8"))
    end

    def csv_for_each(key)
      sanitize_csv key
      line_cache = ""
      CSV.foreach(@config[key], :headers => true, :col_sep => "\#\#\#") do |row|
        yield(row)
        line_cache = "#{row}"
      end
    rescue  CSV::MalformedCSVError => e
      print "\n#{red e.message}"
      print "\nCheck the entry next to this one of #{@config[key]}:\n #{red line_cache}" unless line_cache.size<1
    end

    def write_csv(key, data_ids)
      CSV.open(new_path_for_csv(key), "wb") do |csv|
        csv << @headers[key]
        data_ids.each do |id, row|
          csv << @headers[key].map {|attribute| row[attribute] }
        end
      end
    end

    def new_path_for_csv(key)
      filename = "#{key.to_s.camelize}.csv"
      return new_path_for_csv(:user).
          gsub(/\w*\.csv/, filename) if @config[key].nil?

      old_path = File.dirname @config[key]

      new_path = old_path << "/terraling/"
      FileUtils.mkdir_p new_path
      new_path << filename
      return new_path
    end

    def get_yaml_path()
      new_path_for_csv(:user).gsub(/\w*\.csv/, "import.yml")
    end

    def red(string)
      "\e[31m#{string}\e[0m"
    end

    def show_error(ling_property)
      puts "\n#{red "ERROR: Cannot find reference for"}"
      puts "\t#{ling_property["lang"]}:#{ling_property["name"]}:#{ling_property["value"]}\n"
      alternatives = search_alternatives ling_property
      if alternatives.any?
        puts "#{red "What I found in your languages file is:" }"
        alternatives.each do |property|
          puts "#{property}"
        end
      else
        puts "#{red "I haven't found any entry in languages file!!!" }"
      end
      puts "\n"
    end

    def search_alternatives(ling_property)
      result = []
      ["Yes", "No", "NA", "Not Yet Set"].each do |value|
        index = "#{ling_property["lang"]}:#{ling_property["name"]}:#{value}"
        found = lings_property_ids[index]
        found.nil? ? next : result << index
      end
      result
    end

    def sanitize_text_in_fields(key)
      file = @config[key]
      bad_string = '\r\n"'
      string_fixed = "\#"
      text = File.read(file){|f| f.readline}
      new_text = text.gsub(/#{bad_string}/, string_fixed)
      File.open(file, "w") {|file| file.puts new_text}
    end

    def seconds_fraction_to_time(time_difference)
      hours = (time_difference / 3600).to_i
      mins = ((time_difference / 3600 - hours) * 60).to_i
      seconds = (time_difference % 60 ).to_i
      [hours,mins,seconds]
    end

    def load_headers
      { :user => ["name","id","email","access_level","password"],
        :group => ["id", "name" ,"privacy", "depth_maximum", "ling0_name", "ling1_name", "property_name", "category_name", "lings_property_name", "example_name", "examples_lings_property_name", "example_fields" ],
        :membership => [ "id", "member_id", "group_id", "level", "creator_id" ],
        :ling => [ "id","name","parent_id","depth","group_id", "creator_id" ],
        :category => [ "id","name","depth","group_id","description", "creator_id" ],
        :property => [ "id","name","description","category_id","group_id", "creator_id" ],
        :example => [ "id","ling_id","group_id","name", "creator_id" ],
        :lings_property => [ "id","ling_id","property_id","value","group_id", "creator_id" ],
        :examples_lings_property => [ "id","example_id","lings_property_id","group_id", "creator_id" ],
        :stored_value => [ "id","storable_id","storable_type","key","value","group_id" ]
      }
    end

  end

end