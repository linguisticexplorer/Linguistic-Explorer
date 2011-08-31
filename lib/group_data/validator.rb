# GroupDataImporter
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
    end

    def validate!

      reset = "\r\e[0K"

      @check_users = true
      print "processing users..."
      i = 0
      total = csv_size(:user)
      csv_for_each :user do |row|
        user = true
        row.each do |field|
          user &= field[1].present?
        end

        puts "\n#{red("ERROR")} - Missing parameter in User.csv - line #{i+1}" unless user
        progress_loading(:user, i, total) if user
        i += 1

        @check_users &= user
        # cache user id
        user_ids[row["id"]] = true
      end

      add_check_all(@check_users)

      print "#{reset}processing users...[OK]"

      @check_groups = true
      print "\nprocessing groups..."
      i = 0
      total = csv_size(:group)

      # This function will change the header
      # due to a typo on the project
      fix_csv_elp_name

      csv_for_each :group do |row|
        group = true
        row.each do |field|
          group &= field[1].present?
          print "\n==> #{red(field[0])}" unless group
        end
        print "\n#{red("ERROR")} - Missing parameter in Group.csv - line #{i+1}" unless group

        progress_loading(:group, i, total) if group
        i += 1

        @check_groups &= group
        # cache group id
        groups[row["id"]] = true
      end

      add_check_all(@check_groups)

      print "#{reset}processing groups...[OK]"

      print "\nprocessing memberships..."
      i = 0
      total = csv_size(:membership)
      @check_memberships = true
      csv_for_each :membership do |row|
        membership = true
        row.each do |field|
          membership &= field[1].present? unless field[0]=="creator_id"
        end
        print "\n#{red("ERROR")} - Missing parameter in Membership.csv - line #{i+1}" unless membership

        membership &= groups[row["group_id"]] if membership
        print "\n#{red("ERROR")} - Foreign Key check fails in Membership.csv - [Group_ID] line #{i+1}" unless membership

        membership &= user_ids[row["creator_id"]] if row["creator_id"].present?
        print "\n#{red("ERROR")} - Foreign Key check fails in Membership.csv - [Creator_ID] line #{i+1}" unless membership && row["creator_id"].present?

        progress_loading(:membership, i, total) if membership
        i += 1

        @check_memberships &= membership
      end

      add_check_all(@check_memberships)

      print "#{reset}processing memberships...[OK]"

      print "\nprocessing lings..."
      i = 0
      total = csv_size(:ling)
      @check_lings = true
      csv_for_each :ling do |row|
        ling = true
        row.each do |field|
          ling &= field[1].present? unless field[0]=="creator_id" || field[0]=="parent_id"
        end
        print "\n#{red("ERROR")} - Missing parameter in Ling.csv - line #{i+1}" unless ling

        ling &= groups[row["group_id"]] if ling
        print "\n#{red("ERROR")} - Foreign Key check fails in Ling.csv - [Group_ID] line #{i+1}" unless ling

        ling &= user_ids[row["creator_id"]] if row["creator_id"].present?
        print "\n#{red("ERROR")} - Foreign Key check fails in Ling.csv - [Creator_ID] line #{i+1}" unless ling && row["creator_id"].present?

        progress_loading(:ling, i, total) if ling
        i += 1

        @check_lings &= ling
        # cache ling id
        ling_ids[row["id"]] = true
      end

      add_check_all(@check_lings)

      print "#{reset}processing lings...[OK]"

      print "\nprocessing ling associations..."
      i = 0
      total = csv_size(:ling)
      @check_parents = true
      csv_for_each :ling do |row|
        next if row["parent_id"].blank?
        parent = ling_ids[row["parent_id"]]

        print "\n#{red("ERROR")} - Key check fails in Ling.csv - [Parent_ID] line #{i+1}" unless parent
        progress_loading(:ling, i, total) if parent
        i += 1

        @check_parents &= parent
      end

      add_check_all(@check_parents)

      print "#{reset}processing ling associations...[OK]"

      print "\nprocessing categories..."
      i = 0
      total = csv_size(:category)
      @check_categories = true
      csv_for_each :category do |row|
        category = true
        row.each do |field|
          category &= field[1].present? unless field[0]=="creator_id"
        end
        print "\n#{red("ERROR")} - Missing parameter in Category.csv - line #{i+1}" unless category

        category &= groups[row["group_id"]] if category
        print "\n#{red("ERROR")} - Foreign Key check fails in Category.csv - [Group_ID] line #{i+1}" unless category

        category &= user_ids[row["creator_id"]] if row["creator_id"].present?
        print "\n#{red("ERROR")} - Foreign Key check fails in Category.csv - [Creator_ID] line #{i+1}" unless category && row["creator_id"].present?

        progress_loading(:category, i, total) if category
        i += 1

        @check_categories &= category
        # cache category id
        category_ids[row["id"]] = true
      end

      add_check_all(@check_categories)

      print "#{reset}processing categories...[OK]"

      print "\nprocessing properties..."
      i = 0
      total = csv_size(:property)
      @check_properties = true
      csv_for_each :property do |row|
        property = true
        row.each do |field|
          property &= field[1].present? unless field[0]=="creator_id"
        end

        print "\n#{red("ERROR")} - Missing parameter in Property.csv - line #{i+1}" unless property

        property &= groups[row["group_id"]] if property
        print "\n#{red("ERROR")} - Foreign Key check fails in Property.csv - [Group_ID] line #{i+1}" unless property

        property &= category_ids[row["category_id"]] if property
        print "\n#{red("ERROR")} - Foreign Key check fails in Property.csv - [Category_ID] line #{i+1}" unless property

        property &= user_ids[row["creator_id"]] if row["creator_id"].present?
        print "\n#{red("ERROR")} - Foreign Key check fails in Property.csv - [Creator_ID] line #{i+1}" unless property && row["creator_id"].present?


        progress_loading(:property, i, total) if property
        i += 1

        @check_properties &= property
        # cache property id
        property_ids[row["id"]] = true
      end

      add_check_all(@check_properties)

      print "#{reset}processing properties...[OK]"

      print "\nprocessing examples..."
      i = 0
      total = csv_size(:example)
      @check_examples = true
      csv_for_each :example do |row|
        example = true
        row.each do |field|
          example &= field[1].present? unless field[0]=="creator_id"
        end

        print "\n#{red("ERROR")} - Missing parameter in Example.csv - line #{i+1}" unless example

        example &= groups[row["group_id"]] if example
        print "\n#{red("ERROR")} - Foreign Key check fails in Example.csv - [Group_ID] line #{i+1}" unless example

        example &= ling_ids[row["ling_id"]] if example
        print "\n#{red("ERROR")} - Foreign Key check fails in Example.csv - [Ling_ID] line #{i+1}" unless example

        example &= user_ids[row["creator_id"]] if row["creator_id"].present?
        print "\n#{red("ERROR")} - Foreign Key check fails in Example.csv - [Creator_ID] line #{i+1}" unless example && row["creator_id"].present?

        progress_loading(:example, i, total) if example
        i += 1

        @check_examples &= example
        # cache example id
        example_ids[row["id"]] = true
      end

      add_check_all(@check_examples)

      print "#{reset}processing examples...[OK]"

      print "\nprocessing lings_property..."
      i = 0
      total = csv_size(:lings_property)
      @check_lings_properties = true
      csv_for_each :lings_property do |row|
        lp = true
        row.each do |field|
          lp &= field[1].present? unless field[0]=="creator_id"
        end

        print "\n#{red("ERROR")} - Missing parameter in Ling_property.csv - line #{i+1}" unless lp

        lp &= groups[row["group_id"]] if lp
        print "\n#{red("ERROR")} - Foreign Key check fails in Ling_property.csv - [Group_ID] line #{i+1}" unless lp

        lp &= ling_ids[row["ling_id"]] if lp
        print "\n#{red("ERROR")} - Foreign Key check fails in Ling_property.csv - [Ling_ID] line #{i+1}" unless lp

        lp &= user_ids[row["creator_id"]] if row["creator_id"].present?
        print "\n#{red("ERROR")} - Foreign Key check fails in Ling_property.csv - [Creator_ID] line #{i+1}" unless lp && row["creator_id"].present?

        progress_loading(:lings_property, i, total) if lp
        i += 1

        @check_lings_properties &= lp

        break if !check_lings_properties
        # cache lings_property id
        lings_property_ids[row["id"]] = true
      end

      add_check_all(@check_lings_properties)

      print "#{reset}processing lings_property...[OK]"

      print "\nprocessing examples_lings_property..."
      i = 0
      total = csv_size(:examples_lings_property)
      @check_examples_lp = true
      csv_for_each :examples_lings_property do |row|
        elp = true
        row.each do |field|
           elp &= field[1].present? unless field[0]=="creator_id"
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

        progress_loading(:examples_lings_property, i, total) if elp
        i += 1

        @check_examples_lp &= elp
      end

      add_check_all(@check_examples_lp)

      print "#{reset}processing examples_lings_property...[OK]"

      print "\nprocessing stored_values..."
      i = 0
      total = csv_size(:stored_value)
      @check_stored_values = true
      csv_for_each :stored_value do |row|
        value = true
        row.each do |field|
          value &= field[1].present?
        end

        print "\n#{red("ERROR")} - Missing parameter in Stored_value.csv - line #{i+1}" unless value

        value &= groups[row["group_id"]]
        print "\n#{red("ERROR")} - Foreign Key check fails in Example_ling_property.csv - [Group_ID] line #{i+1}" unless value


        progress_loading(:stored_value, i, total)
        i += 1

        @check_stored_values &= value
      end

      add_check_all(@check_stored_values)
      print "#{reset}processing stored_values...[OK]\n"

      @check_all
    end

    private

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
      string_fixed = "examples_lings_property_name"
      bad_string = "example_lings_property_name"
      content = []

      # Load CSV header and fix it
      header = (CSV.read file).shift
      typo = (header[header.length-2].match string_fixed).nil?
      header[header.length-2] = string_fixed if typo

      # For each line fix key value
      CSV.foreach(file, :headers => true) do |row|
        new_row = row.to_hash
        new_row[string_fixed] = new_row.delete(bad_string) if typo
        content << new_row
      end

      CSV.open(file, "wb") do |csv|
        csv << header
        content.each do |row|
          csv <<  header.map {|attribute| row[attribute]}
        end
      end
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
        #print "#{reset}processing #{key.to_s}...#{i.to_i}%"
      end

    end

    def add_check_all(check_partial)
      @check_all &= check_partial
      puts unless @check_all
      exit(1) unless @check_all
    end

  end

end