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

    FOREIGN_KEY = 1
    MISSING = 2
    HEADER = 3
    VALIDITY_CHECK = 4
    LOWERCASE = 5

    attr_reader :check_all, :check_users, :check_groups, :check_memberships,
                :check_categories, :check_lings, :check_properties, :check_lings_properties,
                :check_examples_lp, :check_stored_values, :check_examples, :check_parents

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
      line = reset_line

      add_check_all(validate_csv_header :user, @check_users)
      csv_for_each :user do |row|
        user = true
        row.each do |col, value|
          user &= value.present?
        end

        print_error MISSING, :user, line unless user

        @check_users &= user
        # cache user id
        user_ids[row["id"]] = true

        progress_loading(:user, line, csv_size(:user)) if user
        line += 1
        break unless user
      end

      add_check_all(@check_users)

      print "#{reset}processing users...[OK]"

      @check_groups = true
      print "\nprocessing groups..."
      line = reset_line

      add_check_all(validate_csv_header :group, @check_groups)

      # This function will change the header
      # due to a very common typo on csv
      fix_csv_elp_name

      csv_for_each :group do |row|
        group = true
        row.each do |col, value|
          group &= value.present?
        end
        print_error MISSING, :group, line unless group

        group &= row["privacy"].downcase == "public" || row["privacy"].downcase == "private"
        print_error VALIDITY_CHECK, :group, line, "privacy", "Privacy", row["privacy"] unless group

        group &= !row["privacy"].downcase!
        print_error LOWERCASE, :membership, line, "privacy",  "Privacy", row["privacy"] unless group

        @check_groups &= group
        # cache group id
        groups[row["id"]] = true

        progress_loading(:group, line, csv_size(:group)) if group
        line += 1
        break unless group
      end

      add_check_all(@check_groups)

      print "#{reset}processing groups...[OK]"

      print "\nprocessing memberships..."
      line = reset_line

      @check_memberships = true

      add_check_all(validate_csv_header :membership, @check_memberships)
      csv_for_each :membership do |row|
        membership = true
        row.each do |col, value|
          membership &= value.present? unless col=="creator_id"
        end
        print_error MISSING, :membership, line unless membership

        membership &= groups[row["group_id"]] if membership
        print_error FOREIGN_KEY, :membership, line, "group_id" unless membership

        if row["creator_id"].present?
          membership &= user_ids[row["creator_id"]]
          print_error FOREIGN_KEY, :membership, line, "creator_id" unless membership
        end

        membership &= row["level"].downcase == "admin" || row["level"].downcase == "member"
        print_error VALIDITY_CHECK, :membership, line, "level", "Access Level", row["level"] unless membership

        membership &= !row["level"].downcase!
        print_error LOWERCASE, :membership, line, "level", "Access Level", row["level"] unless membership

        @check_memberships &= membership
        progress_loading(:membership, line, csv_size(:membership)) if membership
        line += 1

        break unless membership
      end

      add_check_all(@check_memberships)

      print "#{reset}processing memberships...[OK]"

      print "\nprocessing lings..."
      line = reset_line

      @check_lings = true

      add_check_all(validate_csv_header :ling, @check_lings)
      csv_for_each :ling do |row|
        ling = true
        row.each do |col, value|
          ling &= value.present? unless col=="creator_id" || col=="parent_id"
        end
        print_error MISSING, :ling, line unless ling

        ling &= groups[row["group_id"]] if ling
        print_error FOREIGN_KEY, :ling, line, "group_id" unless ling

        if row["creator_id"].present?
          ling &= user_ids[row["creator_id"]] if ling
          print_error FOREIGN_KEY, :ling, line, "creator_id" unless ling
        end

        @check_lings &= ling
        # cache ling id
        ling_ids[row["id"]] = row["group_id"]

        progress_loading :ling, line, csv_size(:ling) if ling
        line += 1
        break unless ling
      end

      add_check_all(@check_lings)

      print "#{reset}processing lings...[OK]"

      print "\nprocessing ling associations..."
      line = reset_line

      @check_parents = true
      csv_for_each :ling do |row|
        next if row["parent_id"].blank?

        parent = ling_ids[row["parent_id"]].present?
        print_error FOREIGN_KEY, :ling, line, "parent_id" unless parent

        parent &= ling_ids[row["parent_id"]] == row["group_id"]
        print_error FOREIGN_KEY, :ling, line, "group_id" unless parent
        print "\n=> Should be '#{ling_ids[row["parent_id"]]}' instead of '#{row["group_id"]}'" unless parent

        @check_parents &= parent

        progress_loading(:ling, line, csv_size(:ling)) if parent
        line += 1
        break unless parent
      end

      add_check_all(@check_parents)

      print "#{reset}processing ling associations...[OK]"

      print "\nprocessing categories..."
      line = reset_line

      @check_categories = true

      add_check_all(validate_csv_header :category, @check_categories)
      csv_for_each :category do |row|
        category = true
        row.each do |col, value|
          category &= value.present? unless col=="creator_id" || col=="description"
        end
        print_error MISSING, :category, line unless category

        category &= groups[row["group_id"]] if category
        print_error FOREIGN_KEY, :category, line, "group_id" unless category

        if row["creator_id"].present?
          category &= user_ids[row["creator_id"]]
          print_error FOREIGN_KEY, :category, line, "creator_id" unless category
        end

        @check_categories &= category

        # cache category id
        category_ids[row["id"]] = true

        progress_loading(:category, line, csv_size(:category)) if category
        line += 1
        break unless category
      end

      add_check_all(@check_categories)

      print "#{reset}processing categories...[OK]"

      print "\nprocessing properties..."
      line = reset_line

      @check_properties = true

      add_check_all(validate_csv_header :property, @check_properties)
      csv_for_each :property do |row|
        property = true
        row.each do |col, value|
          property &= value.present? unless col=="creator_id" || col=="description"
        end

        print_error MISSING, :property, line unless property

        property &= groups[row["group_id"]] if property
        print_error FOREIGN_KEY, :property, line, "group_id" unless property

        property &= category_ids[row["category_id"]] if property
        print_error FOREIGN_KEY, :property, line, "category_id" unless property

        if row["creator_id"].present?
          property &= user_ids[row["creator_id"]]
          print_error FOREIGN_KEY, :property, line, "creator_id" unless property
        end

        @check_properties &= property
        # cache property id
        property_ids[row["id"]] = true

        progress_loading(:property, line, csv_size(:property)) if property
        line += 1
        break unless property
      end

      add_check_all(@check_properties)

      print "#{reset}processing properties...[OK]"

      print "\nprocessing examples..."
      line = reset_line

      @check_examples = true

      add_check_all(validate_csv_header :example, @check_examples)
      csv_for_each :example do |row|
        example = true
        row.each do |col, value|
          example &= value.present? unless col=="creator_id"
        end

        print_error MISSING, :example, line unless example

        example &= groups[row["group_id"]] if example
        print_error FOREIGN_KEY, :example, line, "group_id" unless example

        example &= ling_ids[row["ling_id"]] if example
        print_error FOREIGN_KEY, :example, line, "ling_id" unless example

        if row["creator_id"].present?
          example &= user_ids[row["creator_id"]]
          print_error FOREIGN_KEY, :example, line, "creator_id" unless example
        end

        @check_examples &= example
        # cache example id
        example_ids[row["id"]] = true

        progress_loading(:example, line, csv_size(:example)) if example
        line += 1
        break unless example
      end

      add_check_all(@check_examples)

      print "#{reset}processing examples...[OK]"

      print "\nprocessing lings_property..."
      line = reset_line

      @check_lings_properties = true

      add_check_all(validate_csv_header :lings_property, @check_lings_properties)
      csv_for_each :lings_property do |row|
        lp = true
        row.each do |col, value|
          lp &= value.present? unless col=="creator_id"
        end

        print_error MISSING, :lings_property, line unless lp

        lp &= groups[row["group_id"]] if lp
        print_error FOREIGN_KEY, :lings_property, line, "group_id" unless lp

        lp &= ling_ids[row["ling_id"]] if lp
        print_error FOREIGN_KEY, :lings_property, line, "ling_id" unless lp

        if row["creator_id"].present?
          lp &= user_ids[row["creator_id"]]
          print_error FOREIGN_KEY, :lings_property, line, "creator_id" unless lp
        end

        @check_lings_properties &= lp

        # cache lings_property id
        lings_property_ids[row["id"]] = true

        progress_loading(:lings_property, line, csv_size(:lings_property)) if lp
        line += 1
        break unless lp
      end

      add_check_all(@check_lings_properties)

      print "#{reset}processing lings_property...[OK]"

      print "\nprocessing examples_lings_property..."
      line = reset_line

      @check_examples_lp = true

      add_check_all(validate_csv_header :examples_lings_property, @check_examples_lp)
      csv_for_each :examples_lings_property do |row|
        elp = true
        row.each do |col, value|
          elp &= value.present? unless col=="creator_id"
        end

        print_error MISSING, :examples_lings_property, line unless elp

        elp &= groups[row["group_id"]]
        print_error FOREIGN_KEY, :examples_lings_property, line, "group_id" unless elp

        elp &= lings_property_ids[row["lings_property_id"]]
        print_error FOREIGN_KEY, :examples_lings_property, line, "lings_property_id" unless elp

        elp &= example_ids[row["example_id"]]
        print_error FOREIGN_KEY, :examples_lings_property, line, "example_id" unless elp

        if row["creator_id"].present?
          elp &= user_ids[row["creator_id"]]
          print_error FOREIGN_KEY, :examples_lings_property, line, "example_id" unless elp
        end

        @check_examples_lp &= elp

        progress_loading(:examples_lings_property, line, csv_size(:examples_lings_property)) if elp
        line += 1
        break unless elp
      end

      add_check_all(@check_examples_lp)

      print "#{reset}processing examples_lings_property...[OK]"

      print "\nprocessing stored_values..."
      line = reset_line

      @check_stored_values = true

      add_check_all(validate_csv_header :stored_value, @check_stored_values)
      csv_for_each :stored_value do |row|
        stored_value = true
        row.each do |col, value|
          stored_value &= value.present?
        end

        print_error MISSING, :stored_value, line unless stored_value

        stored_value &= groups[row["group_id"]]
        print_error FOREIGN_KEY, :stored_value, line, "group_id" unless stored_value

        stored_value &= example_ids[row["storable_id"]]
        print_error FOREIGN_KEY, :stored_value, line, "storable_id" unless stored_value

        @check_stored_values &= stored_value

        progress_loading(:stored_value, line, csv_size(:stored_value))
        line += 1
        break unless stored_value
      end

      add_check_all(@check_stored_values)
      print "#{reset}processing stored_values...[OK]\n"

      elapsed = seconds_fraction_to_time(Time.now - start)
      puts "Time for validation: #{elapsed[0]} : #{elapsed[1]} : #{elapsed[2]}"
      @check_all
    end

    private

    def reset_line()
      return 1
    end

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
        check &= text.match title unless title=="creator_id"

        print_header_error key, title unless check
        break unless check
      end

      return check
    end

    def print_error(type, key, line, *args)
      col, name, value = args
      print "\n#{red("ERROR")} - Foreign Key check fails in #{key.to_s.camelize}.csv - [#{col.capitalize}] line #{line+1}" if type==FOREIGN_KEY
      print "\n#{red("ERROR")} - Missing parameter in #{key.to_s.camelize}.csv - line #{line+1}" if type==MISSING
      print "\n#{red("ERROR")} - Header Validation fails for #{key.to_s.camelize}.csv\n=> Please check for '#{col}' column" if type==HEADER
      print "\n#{red("ERROR")} - #{name} value should be valid in #{key.to_s.camelize}.csv - line #{line+1}\n => '#{value}' not valid" if type==VALIDITY_CHECK
      print "\n#{red("ERROR")} - #{name} should be lowercase in #{key.to_s.camelize}.csv - line #{line+1}" if type==LOWERCASE
      print "\n"
    end

    def print_header_error(key, title)
      print_error HEADER, key, 0, title
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