# GroupDataValidator
#
# ==> Category.csv <==
# id,name,depth,group_id,creator_id,description
#
# ==> Example.csv <==
# id,name,ling_id,group_id,creator_id
#
# ==> ExampleLingsProperty.csv <===
# id,example_id,lings_property_id,group_id,creator_id
#
# ==> Group.csv <==
# id, name, privacy, depth_maximum, ling0_name, ling1_name, property_name, category_name, lings_property_name, example_name, examples_lings_property_name, example_fields
#
# ==> Ling.csv <==
# id,name,parent_id,depth,group_id,creator_id
#
# ==> LingsProperty.csv <==
# id,ling_id,property_id,value,group_id,creator_id
#
# ==> Membership.csv <==
# id,member_id,group_id,level,creator_id
#
# ==> Property.csv <==
# id,name,description,category_id,group_id,creator_id
#
# ===> StoredValue.csv <=====
# id, storable_id, storable_type, key, value, group_id
#
# ==> User.csv <==
# id,name,email,access_level,password
#

require 'csv'

module GroupData
  class Validator

    attr_reader :check_all, :check_users, :check_groups, :check_memberships, :check_categories, :check_lings, :check_properties
    attr_reader :check_lings_properties, :check_examples_lp, :check_stored_values, :check_examples, :check_parents

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
    lazy_init_cache :groups, :user_ids, :ling_ids, :category_ids, :property_ids, :example_ids, :lings_property_ids

    # accepts path to yaml file containing paths to csvs
    def initialize(config)
      @config = config
      @config.symbolize_keys!
      @check_all = true
      @headers = load_headers
    end

    def validate!

      reset = "\r\e[0K"
      start = Time.now

      @check_users = true
      print "processing users..."
      i = 1

      add_check_all(validate_csv_header :user, @check_users)
      csv_for_each :user do |row|
        user = true
        row.each do |col, value|
          user &= value.present?
        end

        puts "\n#{red("ERROR")} - Missing parameter in User.csv - line #{i+1}" unless user

        @check_users &= user
        # cache user id
        user_ids[row["id"]] = true

        progress_loading(:user, i, csv_size(:user)) if user
        i += 1
        break unless user
      end

      add_check_all(@check_users)

      print "#{reset}processing users...[OK]"

      @check_groups = true
      print "\nprocessing groups..."
      i = 1

      add_check_all(validate_csv_header :group, @check_groups)

      # This function will change the header
      # due to a very common typo on csv
      fix_csv_elp_name

      csv_for_each :group do |row|
        group = true
        row.each do |col, value|
          group &= value.present?
        end
        print "\n#{red("ERROR")} - Missing parameter in Group.csv - line #{i+1}" unless group

        group &= row["privacy"].downcase == "public" || row["privacy"].downcase == "private"
        print "\n#{red("ERROR")} - Privacy value should be valid in Group.csv - line #{i+1}\n => '#{row["privacy"]}' not valid" unless group

        group &= !row["privacy"].downcase!
        print "\n#{red("ERROR")} - Privacy should be lowercase in Group.csv - line #{i+1}" unless group

        @check_groups &= group
        # cache group id
        groups[row["id"]] = true

        progress_loading(:group, i, csv_size(:group)) if group
        i += 1
        break unless group
      end

      add_check_all(@check_groups)

      print "#{reset}processing groups...[OK]"

      print "\nprocessing memberships..."
      i = 1

      @check_memberships = true

      add_check_all(validate_csv_header :membership, @check_memberships)
      csv_for_each :membership do |row|
        membership = true
        row.each do |col, value|
          membership &= value.present? unless col=="creator_id"
        end
        print "\n#{red("ERROR")} - Missing parameter in Membership.csv - line #{i+1}" unless membership

        membership &= groups[row["group_id"]] if membership
        print "\n#{red("ERROR")} - Foreign Key check fails in Membership.csv - [Group_ID] line #{i+1}" unless membership

        membership &= user_ids[row["creator_id"]] if row["creator_id"].present?
        print "\n#{red("ERROR")} - Foreign Key check fails in Membership.csv - [Creator_ID] line #{i+1}" unless membership && row["creator_id"].present?

        membership &= row["level"].downcase == "admin" || row["level"].downcase == "member"
        print "\n#{red("ERROR")} - Access Level value should be valid in Membership.csv - line #{i+1}\n => #{row["level"]} not valid" unless membership

        membership &= !row["level"].downcase!
        print "\n#{red("ERROR")} - Access Level should be lowercase in Membership.csv - line #{i+1}" unless membership

        @check_memberships &= membership
        progress_loading(:membership, i, csv_size(:membership)) if membership
        i += 1

        break unless membership
      end

      add_check_all(@check_memberships)

      print "#{reset}processing memberships...[OK]"

      print "\nprocessing lings..."
      i = 1

      @check_lings = true

      add_check_all(validate_csv_header :ling, @check_lings)
      csv_for_each :ling do |row|
        ling = true
        row.each do |col, value|
          ling &= value.present? unless col=="creator_id" || col=="parent_id"
        end
        print "\n#{red("ERROR")} - Missing parameter in Ling.csv - line #{i+1}" unless ling

        ling &= groups[row["group_id"]] if ling
        print "\n#{red("ERROR")} - Foreign Key check fails in Ling.csv - [Group_ID] line #{i+1}" unless ling

        ling &= user_ids[row["creator_id"]] if ling && row["creator_id"].present?
        print "\n#{red("ERROR")} - Foreign Key check fails in Ling.csv - [Creator_ID] line #{i+1}" unless ling && row["creator_id"].present?

        @check_lings &= ling
        # cache ling id
        ling_ids[row["id"]] = row["group_id"]

        progress_loading(:ling, i, csv_size(:ling)) if ling
        i += 1
        break unless ling
      end

      add_check_all(@check_lings)

      print "#{reset}processing lings...[OK]"

      print "\nprocessing ling associations..."
      i = 1

      @check_parents = true
      csv_for_each :ling do |row|
        next if row["parent_id"].blank?

        parent = ling_ids[row["parent_id"]].present?
        print "\n#{red("ERROR")} - Key check fails in Ling.csv - [Parent_ID] line #{i+1}" unless parent

        parent &= ling_ids[row["parent_id"]] == row["group_id"]
        print "\n#{red("ERROR")} - Key check fails in Ling.csv - [Group_ID] line #{i+1}\n=> Should be '#{ling_ids[row["parent_id"]]}' instead of '#{row["group_id"]}'" unless parent

        @check_parents &= parent

        progress_loading(:ling, i, csv_size(:ling)) if parent
        i += 1
        break unless parent
      end

      add_check_all(@check_parents)

      print "#{reset}processing ling associations...[OK]"

      print "\nprocessing categories..."
      i = 1

      @check_categories = true

      add_check_all(validate_csv_header :category, @check_categories)
      csv_for_each :category do |row|
        category = true
        row.each do |col, value|
          category &= value.present? unless col=="creator_id" || col=="description"
        end
        print "\n#{red("ERROR")} - Missing parameter in Category.csv - line #{i+1}" unless category

        category &= groups[row["group_id"]] if category
        print "\n#{red("ERROR")} - Foreign Key check fails in Category.csv - [Group_ID] line #{i+1}" unless category

        category &= user_ids[row["creator_id"]] if row["creator_id"].present?
        print "\n#{red("ERROR")} - Foreign Key check fails in Category.csv - [Creator_ID] line #{i+1}" unless category && row["creator_id"].present?

        @check_categories &= category

        # cache category id
        category_ids[row["id"]] = true

        progress_loading(:category, i, csv_size(:category)) if category
        i += 1
        break unless category
      end

      add_check_all(@check_categories)

      print "#{reset}processing categories...[OK]"

      print "\nprocessing properties..."
      i = 1

      @check_properties = true

      add_check_all(validate_csv_header :property, @check_properties)
      csv_for_each :property do |row|
        property = true
        row.each do |col, value|
          property &= value.present? unless col=="creator_id" || col=="description"
        end

        print "\n#{red("ERROR")} - Missing parameter in Property.csv - line #{i+1}" unless property

        property &= groups[row["group_id"]] if property
        print "\n#{red("ERROR")} - Foreign Key check fails in Property.csv - [Group_ID] line #{i+1}" unless property

        property &= category_ids[row["category_id"]] if property
        print "\n#{red("ERROR")} - Foreign Key check fails in Property.csv - [Category_ID] line #{i+1}" unless property

        property &= user_ids[row["creator_id"]] if row["creator_id"].present?
        print "\n#{red("ERROR")} - Foreign Key check fails in Property.csv - [Creator_ID] line #{i+1}" unless property && row["creator_id"].present?

        @check_properties &= property
        # cache property id
        property_ids[row["id"]] = true

        progress_loading(:property, i, csv_size(:property)) if property
        i += 1
        break unless property
      end

      add_check_all(@check_properties)

      print "#{reset}processing properties...[OK]"

      print "\nprocessing examples..."
      i = 1

      @check_examples = true

      add_check_all(validate_csv_header :example, @check_examples)
      csv_for_each :example do |row|
        example = true
        row.each do |col, value|
          example &= value.present? unless col=="creator_id"
        end

        print "\n#{red("ERROR")} - Missing parameter in Example.csv - line #{i+1}" unless example

        example &= groups[row["group_id"]] if example
        print "\n#{red("ERROR")} - Foreign Key check fails in Example.csv - [Group_ID] line #{i+1}" unless example

        example &= ling_ids[row["ling_id"]] if example
        print "\n#{red("ERROR")} - Foreign Key check fails in Example.csv - [Ling_ID] line #{i+1}" unless example

        example &= user_ids[row["creator_id"]] if row["creator_id"].present?
        print "\n#{red("ERROR")} - Foreign Key check fails in Example.csv - [Creator_ID] line #{i+1}" unless example && row["creator_id"].present?

        @check_examples &= example
        # cache example id
        example_ids[row["id"]] = true

        progress_loading(:example, i, csv_size(:example)) if example
        i += 1
        break unless example
      end

      add_check_all(@check_examples)

      print "#{reset}processing examples...[OK]"

      print "\nprocessing lings_property..."
      i = 1

      @check_lings_properties = true

      add_check_all(validate_csv_header :lings_property, @check_lings_properties)
      csv_for_each :lings_property do |row|
        lp = true
        row.each do |col, value|
          lp &= value.present? unless col=="creator_id"
        end

        print "\n#{red("ERROR")} - Missing parameter in Ling_property.csv - line #{i+1}" unless lp

        lp &= groups[row["group_id"]] if lp
        print "\n#{red("ERROR")} - Foreign Key check fails in Ling_property.csv - [Group_ID] line #{i+1}" unless lp

        lp &= ling_ids[row["ling_id"]] if lp
        print "\n#{red("ERROR")} - Foreign Key check fails in Ling_property.csv - [Ling_ID] line #{i+1}" unless lp

        lp &= user_ids[row["creator_id"]] if row["creator_id"].present?
        print "\n#{red("ERROR")} - Foreign Key check fails in Ling_property.csv - [Creator_ID] line #{i+1}" unless lp && row["creator_id"].present?

        @check_lings_properties &= lp

        # cache lings_property id
        lings_property_ids[row["id"]] = true

        progress_loading(:lings_property, i, csv_size(:lings_property)) if lp
        i += 1
        break unless lp
      end

      add_check_all(@check_lings_properties)

      print "#{reset}processing lings_property...[OK]"

      print "\nprocessing examples_lings_property..."
      i = 1

      @check_examples_lp = true

      add_check_all(validate_csv_header :examples_lings_property, @check_examples_lp)
      csv_for_each :examples_lings_property do |row|
        elp = true
        row.each do |col, value|
          elp &= value.present? unless col=="creator_id"
        end

        print "\n#{red("ERROR")} - Missing parameter in Example_ling_property.csv - line #{i+1}" unless elp

        elp &= groups[row["group_id"]]
        print "\n#{red("ERROR")} - Foreign Key check fails in Example_ling_property.csv - [Group_ID] line #{i+1}" unless elp

        elp &= lings_property_ids[row["lings_property_id"]]
        print "\n#{red("ERROR")} - Foreign Key check fails in Example_ling_property.csv - [Ling_ID] line #{i+1}" unless elp

        elp &= example_ids[row["example_id"]]
        print "\n#{red("ERROR")} - Foreign Key check fails in Example_ling_property.csv - [Example_ID] line #{i+1}" unless elp

        elp &= user_ids[row["creator_id"]] if row["creator_id"].present?
        print "\n#{red("ERROR")} - Foreign Key check fails in Example_ling_property.csv - [Creator_ID] line #{i+1}" unless elp && row["creator_id"].present?

        @check_examples_lp &= elp

        progress_loading(:examples_lings_property, i, csv_size(:examples_lings_property)) if elp
        i += 1
        break unless elp
      end

      add_check_all(@check_examples_lp)

      print "#{reset}processing examples_lings_property...[OK]"

      print "\nprocessing stored_values..."
      i = 1

      @check_stored_values = true

      add_check_all(validate_csv_header :stored_value, @check_stored_values)
      csv_for_each :stored_value do |row|
        stored_value = true
        row.each do |col, value|
          stored_value &= value.present?
        end

        print "\n#{red("ERROR")} - Missing parameter in Stored_value.csv - line #{i+1}" unless stored_value

        stored_value &= groups[row["group_id"]]
        print "\n#{red("ERROR")} - Foreign Key check fails in Example_ling_property.csv - [Group_ID] line #{i+1}" unless stored_value

        @check_stored_values &= stored_value

        progress_loading(:stored_value, i, csv_size(:stored_value))
        i += 1
        break unless stored_value
      end

      add_check_all(@check_stored_values)
      print "#{reset}processing stored_values...[OK]\n"

      elapsed = seconds_fraction_to_time(Time.now - start)
      puts "Time for validation: #{elapsed[0]} : #{elapsed[1]} : #{elapsed[2]}"
      @check_all
    end

    private

    def seconds_fraction_to_time(time_difference)
      hours = (time_difference / 3600).to_i
      mins = ((time_difference / 3600 - hours) * 60).to_i
      seconds = (time_difference % 60 ).to_i
      [hours,mins,seconds]
    end

    def csv_for_each(key)
      CSV.foreach(@config[key], :headers => true) do |row|
        yield(row)
      end
    end

    def csv_size(key)
      (CSV.read(@config[key]).length) -1
    end

    def fix_csv_elp_name
      # Load the CSV file
      file = @config[:group]
      string_fixed = "examples_lings_property_name,"
      bad_string = "example_lings_propert"

      text = File.read(file){|f| f.readline}
      new_text = text.gsub(/#{bad_string}.*,/, string_fixed)
      File.open(file, "w") {|file| file.puts new_text}
    end

    def validate_csv_header(key, check)
      file = @config[key]
      text = File.read(file){|f| f.readline}
      header = @headers[key]

      header.each do |title|
        check &= text.match title

        print "\n#{red("ERROR")} - Header Validation fails for #{key}\n=> Please check for '#{title}' column" unless check
        break unless check
      end

      return check
    end

    def red(string)
      "\e[31m#{string}\e[0m"
    end

    # Thanks to http://snippets.dzone.com/posts/show/3760 proof-of-concept
    def progress_loading(key, progress_value, max_value)
      # move cursor to beginning of line
      cr = "\r"
      prec_i = -1

      # ANSI escape code to clear line from cursor to end of line
      # "\e" is an alternative to "\033"
      # cf. http://en.wikipedia.org/wiki/ANSI_escape_code

      clear = "\e[0K"

      # reset lines
      reset = cr + clear

      i = progress_value.round(2) / max_value *100
      if(prec_i < i.truncate && progress_value<max_value)
        $stdout.flush
        prec_i = i.to_i
        print "#{reset}processing #{key.to_s}...#{i.to_i}%"
      end

    end

    def add_check_all(check_partial)
      @check_all &= check_partial
      puts unless @check_all
      exit(1) unless @check_all
    end

    def load_headers
      { :user => ["name","id","email","access_level","password"],
        :group => ["id", "name" ,"privacy", "depth_maximum", "ling0_name", "ling1_name", "property_name", "category_name", "lings_property_name", "example_name", "examples_lings_property_name", "example_fields" ],
        :membership => [ "id", "member_id", "group_id", "level", "creator_id" ],
        :ling => [ "id","name","parent_id","depth","group_id","creator_id" ],
        :category => [ "id","name","depth","group_id","creator_id","description" ],
        :property => [ "id","name","description","category_id","group_id","creator_id" ],
        :example => [ "id","ling_id","group_id","creator_id","name" ],
        :lings_property => [ "id","ling_id","property_id","value","group_id","creator_id" ],
        :examples_lings_property => [ "id","example_id","lings_property_id","group_id","creator_id" ],
        :stored_value => [ "id","storable_id","storable_type","key","value","group_id" ]
      }
    end

  end

end