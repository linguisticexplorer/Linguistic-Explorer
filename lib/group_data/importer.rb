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
require 'iconv'
#require 'ruby-prof'

module GroupData
  class Importer

    class << self
      def import(config, verbose = true)
        importer = new(config, verbose)
        importer.import!
        importer
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
      @verbose = verbose
    end

    def import!
      #RubyProf.measure_mode = RubyProf::MEMORY
      #RubyProf.start
      reset = "\r\e[0K"

      start = Time.now
      # processing users
      logger.info "processing #{csv_size(:user)} users"
      #puts "processing users"

      print_to_console "processing users..."

      csv_for_each :user do |row|
        user = User.find_or_initialize_by_email(row["email"])
        if user.new_record?
          user.password_confirmation = row["password"]
          # Needed for CAPTCHA
          user.bypass_humanizer = true

          save_model_with_attributes(user, row)
        end

        # cache user id
        user_ids[row["id"]] = user
      end
      print_to_console "#{reset}processing users...[OK]"

      logger.info "processing #{csv_size(:group)} groups"
      print_to_console "\nprocessing groups..."
      #puts "processing groups"

      # This function will change the header
      # due to a typo, if didn't exec
      # the validator before
      fix_csv_elp_name

      csv_for_each :group do |row|
        group = Group.find_or_initialize_by_name(row["name"])
        save_model_with_attributes(group, row)

        # cache group id
        groups[row["id"]] = group
      end
      print_to_console "#{reset}processing groups...[OK]"

      logger.info "processing #{csv_size(:membership)} memberships"
      #puts "processing memberships"

      print_to_console "\nprocessing memberships..."

      csv_for_each :membership do |row|
        group       = groups[row["group_id"]]
        member_id   = user_ids[row["member_id"]].id
        membership  = group.memberships.find_or_initialize_by_member_id(member_id) do |m|
          m.creator = user_ids[row["creator_id"]] if row["creator_id"].present?
        end
        save_model_with_attributes(membership, row)

      end
      print_to_console "#{reset}processing memberships...[OK]"

      logger.info "processing #{csv_size(:ling)} lings"
      #puts "processing lings"

      print_to_console "\nprocessing lings..."

      csv_for_each :ling do |row|
        group     = groups[row["group_id"]]
        ling      = group.lings.find_or_initialize_by_name(row["name"]) do |m|
          m.creator = user_ids[row["creator_id"]] if row["creator_id"].present?
        end
        save_model_with_attributes(ling, row)

        # cache ling id
        ling_ids[row["id"]] = ling.id
      end
      print_to_console "#{reset}processing lings...[OK]"

      logger.info "processing #{csv_size(:ling)} parent/child ling associations"
      #puts "parent/child ling associations"

      print_to_console "\nprocessing ling associations..."

      csv_for_each :ling do |row|
        next if row["parent_id"].blank?
        child   = Ling.find(ling_ids[row["id"]])
        parent  = Ling.find(ling_ids[row["parent_id"]])
        child.parent = parent
        child.save!

      end
      print_to_console "#{reset}processing ling associations...[OK]"

      logger.info "processing #{csv_size(:category)} categories"
      #puts "processing categories"

      print_to_console "\nprocessing categories..."

      csv_for_each :category do |row|
        group     = groups[row["group_id"]]
        category  = group.categories.find_or_initialize_by_name(row["name"]) do |m|
          m.creator = user_ids[row["creator_id"]] if row["creator_id"].present?
        end
        save_model_with_attributes category, row

        # cache category id
        category_ids[row["id"]] = category.id
      end
      print_to_console "#{reset}processing categories...[OK]"

      logger.info "processing #{csv_size(:property)} properties"
      #puts "processing properties"

      print_to_console "\nprocessing properties..."

      csv_for_each :property do |row|
        group    = groups[row["group_id"]]
        category = group.categories.find(category_ids[row["category_id"]])
        property = group.properties.find_or_initialize_by_name(row["name"]) do |p|
          p.category = category
          p.creator = user_ids[row["creator_id"]] if row["creator_id"].present?
        end
        save_model_with_attributes property, row

        # cache property id
        property_ids[row["id"]] = property.id
      end
      print_to_console "#{reset}processing properties...[OK]"

      logger.info "processing #{csv_size(:example)} examples"
      #puts "processing examples"

      print_to_console "\nprocessing examples..."
      Example.transaction do
        csv_for_each :example do |row|
          group    = groups[row["group_id"]]
          ling     = Ling.find(ling_ids[row["ling_id"]])
          example  = group.examples.find_or_initialize_by_name(row["name"]) do |e|
            e.ling = ling
            e.creator = user_ids[row["creator_id"]] if row["creator_id"].present?
          end
          save_model_with_attributes example, row

          # cache example id
          example_ids[row["id"]] = example.id
        end
      end

      print_to_console "#{reset}processing examples...[OK]"

      total = csv_size(:lings_property)
      logger.info "processing #{total} lings_property"

      print_to_console "\nprocessing lings_property..."
      print_to_console " will take about #{total/6000} minutes for #{total} rows" unless total<100000

      LingsProperty.skip_callback(:create)

      LingsProperty.transaction do
        csv_for_each :lings_property do |row|
          group       = groups[row["group_id"]]
          ling_id     = ling_ids[row["ling_id"]]
          value       = row["value"]
          property_id = property_ids[row["property_id"]]
          conditions  = { :value => value, :ling_id => ling_id, :property_id => property_id }

          lp = group.lings_properties.where(conditions).first ||
              group.lings_properties.create(conditions) do |lp|
                lp.creator = user_ids[row["creator_id"]] if row["creator_id"].present?
              end

          # cache lings_property id
          lings_property_ids[row["id"]] = lp.id
        end
      end

      # Restore callbacks
      LingsProperty.set_callback(:create)

      print_to_console "#{reset}processing lings_property...[OK]"

      logger.info "processing #{csv_size(:examples_lings_property)} examples_lings_property"
      print_to_console "\nprocessing examples_lings_property..."

      # Speed up the creation
      ExamplesLingsProperty.skip_callback(:create)

      ExamplesLingsProperty.transaction do
        csv_for_each :examples_lings_property do |row|
          group             = groups[row["group_id"]]
          example_id        = example_ids[row["example_id"]]
          lings_property_id = lings_property_ids[row["lings_property_id"]]
          conditions  = { :example_id => example_id, :lings_property_id => lings_property_id }

          group.examples_lings_properties.where(conditions).first ||
              group.examples_lings_properties.create(conditions) do |elp|
                elp.creator = user_ids[row["creator_id"]] if row["creator_id"].present?
              end
        end

      end

      # Restore callbacks
      ExamplesLingsProperty.set_callback(:create)

      print_to_console "#{reset}processing examples_lings_property...[OK]"

      logger.info "processing #{csv_size(:stored_value)} stored value"
      print_to_console "\nprocessing stored_values..."

      # Speed up
      StoredValue.skip_callback(:create)

      StoredValue.transaction do
        csv_for_each :stored_value do |row|
          value = row["value"].gsub("#{row["key"]}:", '')

          group         = groups[row["group_id"]]
          storable_type = row['storable_type']
          storable_id   = self.send("#{storable_type.downcase}_ids")[row["storable_id"]]
          conditions = { :storable_id => storable_id, :storable_type => storable_type,
                         :key => row["key"], :value => value }

          group.stored_values.where(conditions).first || group.stored_values.create(conditions)


        end
      end

      # Restore callbacks
      StoredValue.set_callback(:create)

      print_to_console "#{reset}processing stored_values...[OK]\n"

      elapsed = seconds_fraction_to_time(Time.now - start)
      print_to_console "Time for import: #{elapsed[0]} : #{elapsed[1]} : #{elapsed[2]}\n"

      #result = RubyProf.stop

      # Print a flat profile to text
      # File.open "#{Rails.root}/tmp/profile-graph.html", 'w' do |file|
      #   RubyProf::GraphHtmlPrinter.new(result).print(file)
      # end

    end

    private

    def print_to_console(string)
      print string if @verbose
    end

    def seconds_fraction_to_time(time_difference)
      hours = (time_difference / 3600).to_i
      mins = ((time_difference / 3600 - hours) * 60).to_i
      seconds = (time_difference % 60 ).to_i
      [hours,mins,seconds]
    end


    def set_creator(conditions, group, row)
      creator = User.find(user_ids[row["creator_id"]])
      conditions[:created_at] = creator.created_at
      conditions[:updated_at] = creator.updated_at
      conditions[:group_id] = group.id
      conditions[:creator_id] = creator.id
    end

    def save_model_with_attributes(model, row)
      model.class.importable_attributes.each do |attribute|
        model.send("#{attribute}=", row[attribute])
      end
      model.class.skip_callback(:create)
      model.save!(:validate => false)
      model.class.set_callback(:create)
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
      string_fixed = "examples_lings_property_name"
      bad_string = "example_lings_property_name"

      text = File.read(file)
      new_text = text.gsub(/#{bad_string}.*,/, string_fixed)
      File.open(file, "w") {|file| file.puts new_text}
    end

    def logger
      @logger ||= begin
        if Rails.env.production?
          Logger.new(STDOUT)
        else
          Rails.logger
        end
      end
    end
  end

end