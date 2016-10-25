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
# ==> Roles.csv <==
# id, resource_id, member_id, group_id

require 'readers/CSVReader'
require 'progressbar'

module GroupData
  class Validator

    attr_reader :check_all, :check_users, :check_groups, :check_memberships,
                :check_categories, :check_lings, :check_properties, :check_lings_properties,
                :check_examples_lp, :check_stored_values, :check_examples, :check_parents, :check_roles

    class << self
      def load(config, verbose=true)
        validator = new(config, verbose)
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
    def initialize(config, verbose)
      @config = config
      @config.symbolize_keys!
      @check_all = true
      @headers = load_headers
      @verbose = verbose
    end

    # disabled progress_loading graphical interface for best performance
    def validate!

      reset = "\r\e[0K"

      @check_users = validate_csv(:user)
      add_check_all(@check_users)

      # This function will change the header
      # due to a very common typo on csv
      fix_csv_elp_name

      @check_groups = validate_csv(:group)
      add_check_all(@check_groups)

      @check_memberships = validate_csv(:membership)
      add_check_all(@check_memberships)

      @check_lings = validate_csv(:ling)
      add_check_all(@check_lings)

      @check_parents = validate_csv(:ling_associations)
      add_check_all(@check_parents)

      @check_categories = validate_csv(:category)
      add_check_all(@check_categories)

      @check_properties = validate_csv(:property)
      add_check_all(@check_properties)

      @check_examples = validate_csv(:example)
      add_check_all(@check_examples)

      @check_lings_properties = validate_csv(:lings_property)
      add_check_all(@check_lings_properties)

      @check_examples_lp = validate_csv(:examples_lings_property)
      add_check_all(@check_examples_lp)

      @check_stored_values = validate_csv(:stored_value)
      add_check_all(@check_stored_values)

      @check_roles = validate_csv(:role)
      add_check_all(@check_roles)

      @check_all
    end

    private

    def validate_csv method_key
      class_key = extract_class_from_method(method_key)
      check = validate_csv_header(class_key, true)
      if check
        line = 1
        #Inizialize a CSVReader to read the right csv
        csv_reader = CSVReader.new(@config[class_key])
        title = method_key.to_s.titleize.pluralize
        total = csv_reader.size

        progress_bar = ProgressBar.new(title, total) if @verbose

        #choose which validate method to run
        validate_method = validate_method_factory(method_key)

        csv_reader.for_each do |row|
          #run the right validate method
          check = validate_method.call(row, line)
          break unless check
          line +=1
          progress_bar.inc if @verbose
        end
        progress_bar.finish  if @verbose
      end

      return check
    end

    def extract_class_from_method method_key
      method_key == :ling_associations ? :ling : method_key
    end

    def validate_method_factory key
      #The name of validate method is <model>_validate_from_csv_row
      validate_method = self.method("#{key.to_s}_validate_from_csv_row")
      Proc.new { |row, line| validate_method.call(row, line) }
    end

    ################################
    # Start list of validate methods
    ################################

    def user_validate_from_csv_row row, line
      user = true
      row.each do |col, value|
        user &= value.present?
      end

      print_error :err_missing, :user, line unless user

      # cache user id
      user_ids[row["id"]] = true

      return user
    end

    def group_validate_from_csv_row row, line
      group = true
      row.each do |col, value|
        group &= value.present?
      end
      print_error :err_missing, :group, line unless group

      group &= row["privacy"].downcase == "public" || row["privacy"].downcase == "private"
      print_error :err_validity, :group, line, "privacy", "Privacy", row["privacy"] unless group

      group &= !row["privacy"].downcase!
      print_error :err_lowercase, :group, line, "privacy",  "Privacy", row["privacy"] unless group

      # cache group id
      groups[row["id"]] = true

      return group
    end

    def membership_validate_from_csv_row row, line
      membership = true
      row.each do |col, value|
        membership &= value.present? unless col=="creator_id"
      end
      print_error :err_missing, :membership, line unless membership

      membership &= groups[row["group_id"]] if membership
      print_error :err_foreign, :membership, line, "group_id" unless membership

      if row["creator_id"].present?
        membership &= user_ids[row["creator_id"]]
        print_error :err_foreign, :membership, line, "creator_id" unless membership
      end

      membership &= row["level"].downcase == "admin" || row["level"].downcase == "member"
      print_error :err_validity, :membership, line, "level", "Access Level", row["level"] unless membership

      membership &= !row["level"].downcase!
      print_error :err_lowercase, :membership, line, "level", "Access Level", row["level"] unless membership

      return membership
    end

    def ling_validate_from_csv_row row, line
      ling = true
      row.each do |col, value|
        ling &= value.present? unless col=="creator_id" || col=="parent_id"
      end
      print_error :err_missing, :ling, line unless ling

      ling &= groups[row["group_id"]] if ling
      print_error :err_foreign, :ling, line, "group_id" unless ling

      if row["creator_id"].present?
        ling &= user_ids[row["creator_id"]] if ling
        print_error :err_foreign, :ling, line, "creator_id" unless ling
      end

      # cache ling id
      ling_ids[row["id"]] = row["group_id"]

      return ling
    end

    def ling_associations_validate_from_csv_row row, line
      parent = true
      if !row["parent_id"].blank?
        parent = ling_ids[row["parent_id"]].present?
        print_error :err_foreign, :ling, line, "parent_id" unless parent

        parent &= ling_ids[row["parent_id"]] == row["group_id"]
        print_error :err_foreign, :ling, line, "group_id" unless parent

        print_to_console "\n=> Should be '#{ling_ids[row["parent_id"]]}' instead of '#{row["group_id"]}'" unless parent
      end
      return parent
    end

    def role_validate_from_csv_row row, line
      role = true
      row.each do |col, value|
        role &= value.present?
      end
      print_error :err_missing, :role, line unless role
      print_error :err_missing, :role, line, "resource_id" unless row["resource_id"].present?
      print_error :err_missing, :role, line, "member_id" unless row["member_id"].present?
      print_error :err_missing, :role, line, "group_id" unless row["group_id"].present?

      return role
    end

    def category_validate_from_csv_row row, line
      category = true
      row.each do |col, value|
        category &= value.present? unless col=="creator_id" || col=="description"
      end
      print_error :err_missing, :category, line unless category

      category &= groups[row["group_id"]] if category
      print_error :err_foreign, :category, line, "group_id" unless category

      if row["creator_id"].present?
        category &= user_ids[row["creator_id"]] if category
        print_error :err_foreign, :category, line, "creator_id" unless category
      end

      # cache category id
      category_ids[row["id"]] = true

      return category
    end

    def property_validate_from_csv_row row, line
      property = true
      row.each do |col, value|
        property &= value.present? unless col=="creator_id" || col=="description"
      end

      print_error :err_missing, :property, line unless property

      property &= groups[row["group_id"]] if property
      print_error :err_foreign, :property, line, "group_id" unless property

      property &= category_ids[row["category_id"]] if property
      print_error :err_foreign, :property, line, "category_id" unless property

      if row["creator_id"].present?
        property &= user_ids[row["creator_id"]] if property
        print_error :err_foreign, :property, line, "creator_id" unless property
      end

      # cache property id
      property_ids[row["id"]] = true

      return property
    end

    def example_validate_from_csv_row row, line
      example = true
      row.each do |col, value|
        example &= value.present? unless col=="creator_id"
      end

      print_error :err_missing, :example, line unless example

      example &= groups[row["group_id"]] if example
      print_error :err_foreign, :example, line, "group_id" unless example

      example &= ling_ids[row["ling_id"]] if example
      print_error :err_foreign, :example, line, "ling_id" unless example

      if row["creator_id"].present?
        example &= user_ids[row["creator_id"]] if example
        print_error :err_foreign, :example, line, "creator_id" unless example
      end

      # cache example id
      example_ids[row["id"]] = true

      return example
    end

    def lings_property_validate_from_csv_row row, line
      lp = true
      row.each do |col, value|
        lp &= value.present? unless col=="creator_id"
      end

      print_error :err_missing, :lings_property, line unless lp

      lp &= groups[row["group_id"]] if lp
      print_error :err_foreign, :lings_property, line, "group_id" unless lp

      lp &= ling_ids[row["ling_id"]] if lp
      print_error :err_foreign, :lings_property, line, "ling_id" unless lp

      if row["creator_id"].present?
        lp &= user_ids[row["creator_id"]] if lp
        print_error :err_foreign, :lings_property, line, "creator_id" unless lp
      end

      # cache lings_property id
      lings_property_ids[row["id"]] = true

      return lp
    end

    def examples_lings_property_validate_from_csv_row row, line
      elp = true
      row.each do |col, value|
        elp &= value.present? unless col=="creator_id"
      end

      print_error :err_missing, :examples_lings_property, line unless elp

      elp &= groups[row["group_id"]] if elp
      print_error :err_foreign, :examples_lings_property, line, "group_id" unless elp

      elp &= lings_property_ids[row["lings_property_id"]] if elp
      print_error :err_foreign, :examples_lings_property, line, "lings_property_id" unless elp

      elp &= example_ids[row["example_id"]] if elp
      print_error :err_foreign, :examples_lings_property, line, "example_id" unless elp

      if row["creator_id"].present?
        elp &= user_ids[row["creator_id"]] if elp
        print_error :err_foreign, :examples_lings_property, line, "example_id" unless elp
      end

      return elp
    end

    def stored_value_validate_from_csv_row row, line
      stored_value = true
      row.each do |col, value|
        stored_value &= value.present?
      end

      print_error :err_missing, :stored_value, line unless stored_value

      stored_value &= groups[row["group_id"]] if stored_value
      print_error :err_foreign, :stored_value, line, "group_id" unless stored_value

      stored_value &= example_ids[row["storable_id"]] if stored_value
      print_error :err_foreign, :stored_value, line, "storable_id" unless stored_value

      return stored_value
    end

    ##############################
    # End list of validate methods
    ##############################

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
      print_to_console "\n#{red("ERROR")} - Foreign Key check fails in #{key.to_s.camelize}.csv - [#{col.capitalize}] line #{line+1}" if type==:err_foreign
      print_to_console "\n#{red("ERROR")} - Missing parameter in #{key.to_s.camelize}.csv - line #{line+1}" if type==:err_missing
      print_to_console "\n#{red("ERROR")} - Header Validation fails for #{key.to_s.camelize}.csv\n=> Please check for '#{col}' column" if type==:err_header
      print_to_console "\n#{red("ERROR")} - #{name} value should be valid in #{key.to_s.camelize}.csv - line #{line+1}\n => '#{value}' not valid" if type==:err_validity
      print_to_console "\n#{red("ERROR")} - #{name} should be lowercase in #{key.to_s.camelize}.csv - line #{line+1}" if type==:err_lowercase
      print_to_console "\n"
    end

    def print_header_error(key, title)
      print_error :err_header, key, 0, title
    end

    def red(string)
      "\e[31m#{string}\e[0m"
    end

    def add_check_all(check_partial)
      @check_all &= check_partial
      print_to_console("\n") unless @check_all
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
        :stored_value => [ "id","storable_id","storable_type","key","value","group_id" ],
        :role => [ "id", "resource_id", "member_id", "group_id" ]
      }
    end

    def print_to_console(string)
      print string if @verbose
    end

  end

end