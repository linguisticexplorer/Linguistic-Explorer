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
require 'progressbar'

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

    #puts "Loading lazy_cache"
    lazy_init_cache :groups, :user_ids, :ling_ids, :category_ids, :property_ids, :example_ids, :lings_property_ids

    # accepts path to yaml file containing paths to csvs
    def initialize(config)
      @config = config
      @config.symbolize_keys!
      @check_all = true
      @headers = load_headers
    end

    # disabled progress_loading graphical interface for best performance
    def validate!

      reset = "\r\e[0K"

      @check_users = true
      line = reset_line

      add_check_all(validate_csv_header :user, @check_users)
      user_bar = ProgressBar.new("Users...", csv_size(:user))
      csv_for_each :user do |row|
        user = true
        row.each do |col, value|
          user &= value.present?
        end

        print_error MISSING, :user, line unless user

        @check_users &= user
        # cache user id
        user_ids[row["id"]] = true
        user_bar.inc
        line += 1
        break unless user
      end
      user_bar.finish
      add_check_all(@check_users)

      @check_groups = true

      add_check_all(validate_csv_header :group, @check_groups)
      line = reset_line
      # This function will change the header
      # due to a very common typo on csv
      fix_csv_elp_name
      group_bar = ProgressBar.new("Groups...", csv_size(:group))
      csv_for_each :group do |row|
        group = true
        row.each do |col, value|
          group &= value.present?
        end
        print_error MISSING, :group, line unless group

        group &= row["privacy"].downcase == "public" || row["privacy"].downcase == "private"
        print_error VALIDITY_CHECK, :group, line, "privacy", "Privacy", row["privacy"] unless group

        group &= !row["privacy"].downcase!
        print_error LOWERCASE, :group, line, "privacy",  "Privacy", row["privacy"] unless group

        @check_groups &= group
        # cache group id
        groups[row["id"]] = true
        group_bar.inc
        line += 1
        break unless group
      end
      group_bar.finish

      add_check_all(@check_groups)

      @check_memberships = true
      line = reset_line
      add_check_all(validate_csv_header :membership, @check_memberships)
      member_bar = ProgressBar.new("Memberships", csv_size(:membership))
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
        line += 1
        member_bar.inc

        break unless membership
      end
      member_bar.finish
      add_check_all(@check_memberships)

      @check_lings = true
      line = reset_line
      add_check_all(validate_csv_header :ling, @check_lings)
      ling_bar = ProgressBar.new("Lings", csv_size(:ling))
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

        line += 1
        ling_bar.inc
        break unless ling
      end
      ling_bar.finish
      add_check_all(@check_lings)
      line = reset_line
      @check_parents = true
      ling_ass_bar = ProgressBar.new("Lings Associations", csv_size(:ling))
      csv_for_each :ling do |row|
        if row["parent_id"].blank?
          ling_ass_bar.inc
          next
        end

        parent = ling_ids[row["parent_id"]].present?
        print_error FOREIGN_KEY, :ling, line, "parent_id" unless parent

        parent &= ling_ids[row["parent_id"]] == row["group_id"]
        print_error FOREIGN_KEY, :ling, line, "group_id" unless parent
        print "\n=> Should be '#{ling_ids[row["parent_id"]]}' instead of '#{row["group_id"]}'" unless parent

        @check_parents &= parent

        line += 1
        ling_ass_bar.inc
        break unless parent
      end
      ling_ass_bar.finish
      add_check_all(@check_parents)

      @check_categories = true
      line = reset_line
      add_check_all(validate_csv_header :category, @check_categories)
      cat_bar = ProgressBar.new("Category", csv_size(:category))
      csv_for_each :category do |row|
        category = true
        row.each do |col, value|
          category &= value.present? unless col=="creator_id" || col=="description"
        end
        print_error MISSING, :category, line unless category

        category &= groups[row["group_id"]] if category
        print_error FOREIGN_KEY, :category, line, "group_id" unless category

        if row["creator_id"].present?
          category &= user_ids[row["creator_id"]] if category
          print_error FOREIGN_KEY, :category, line, "creator_id" unless category
        end

        @check_categories &= category

        # cache category id
        category_ids[row["id"]] = true

        line += 1
        cat_bar.inc
        break unless category
      end
      cat_bar.finish
      add_check_all(@check_categories)

      @check_properties = true
      line = reset_line
      add_check_all(validate_csv_header :property, @check_properties)
      prop_bar = ProgressBar.new("Property", csv_size(:property))
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
          property &= user_ids[row["creator_id"]] if property
          print_error FOREIGN_KEY, :property, line, "creator_id" unless property
        end

        @check_properties &= property
        # cache property id
        property_ids[row["id"]] = true

        line += 1
        prop_bar.inc
        break unless property
      end
      prop_bar.finish
      add_check_all(@check_properties)

      @check_examples = true
      line = reset_line
      add_check_all(validate_csv_header :example, @check_examples)
      ex_bar = ProgressBar.new("Examples", csv_size(:example))
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
          example &= user_ids[row["creator_id"]] if example
          print_error FOREIGN_KEY, :example, line, "creator_id" unless example
        end

        @check_examples &= example
        # cache example id
        example_ids[row["id"]] = true

        line += 1
        ex_bar.inc
        break unless example
      end
      ex_bar.finish
      add_check_all(@check_examples)

      @check_lings_properties = true
      line = reset_line
      add_check_all(validate_csv_header :lings_property, @check_lings_properties)
      lp_bar = ProgressBar.new("Lings Properties", csv_size(:lings_property))
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
          lp &= user_ids[row["creator_id"]] if lp
          print_error FOREIGN_KEY, :lings_property, line, "creator_id" unless lp
        end

        @check_lings_properties &= lp
        lp_bar.inc
        # cache lings_property id
        lings_property_ids[row["id"]] = true

        break unless lp
      end
      lp_bar.finish
      add_check_all(@check_lings_properties)

      @check_examples_lp = true
      line = reset_line
      add_check_all(validate_csv_header :examples_lings_property, @check_examples_lp)
      elp_bar = ProgressBar.new("Examples Lings Properties", csv_size(:examples_lings_property))
      csv_for_each :examples_lings_property do |row|
        elp = true
        row.each do |col, value|
          elp &= value.present? unless col=="creator_id"
        end

        print_error MISSING, :examples_lings_property, line unless elp

        elp &= groups[row["group_id"]] if elp
        print_error FOREIGN_KEY, :examples_lings_property, line, "group_id" unless elp

        elp &= lings_property_ids[row["lings_property_id"]] if elp
        print_error FOREIGN_KEY, :examples_lings_property, line, "lings_property_id" unless elp

        elp &= example_ids[row["example_id"]] if elp
        print_error FOREIGN_KEY, :examples_lings_property, line, "example_id" unless elp

        if row["creator_id"].present?
          elp &= user_ids[row["creator_id"]] if elp
          print_error FOREIGN_KEY, :examples_lings_property, line, "example_id" unless elp
        end

        @check_examples_lp &= elp
        elp_bar.inc
        line += 1
        break unless elp
      end
      elp_bar.finish

      add_check_all(@check_examples_lp)

      @check_stored_values = true
      line = reset_line
      add_check_all(validate_csv_header :stored_value, @check_stored_values)
      sv_bar = ProgressBar.new("Stored Values", csv_size(:stored_value))
      csv_for_each :stored_value do |row|
        stored_value = true
        row.each do |col, value|
          stored_value &= value.present?
        end

        print_error MISSING, :stored_value, line unless stored_value

        stored_value &= groups[row["group_id"]] if stored_value
        print_error FOREIGN_KEY, :stored_value, line, "group_id" unless stored_value

        stored_value &= example_ids[row["storable_id"]] if stored_value
        print_error FOREIGN_KEY, :stored_value, line, "storable_id" unless stored_value

        @check_stored_values &= stored_value

        line += 1
        sv_bar.inc
        break unless stored_value
      end
      sv_bar.finish
      add_check_all(@check_stored_values)
      @check_all
    end

    private

    def reset_line()
      return 1
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