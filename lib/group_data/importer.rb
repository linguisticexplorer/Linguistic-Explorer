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
# ==> Roles.csv <==
# id, resource_id, member_id, group_id

require 'csv'
require 'iconv'
# require 'ruby-prof'
require 'progressbar'

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
              # (instance_variable_set("@#{cache}", "#{cache}" =~ /ids/ ? GoogleHashSparseIntToInt.new : Hash.new) && instance_variable_get("@#{cache}"))
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
      reset = "\r\e[0K"

      start = Time.now
      # processing users
      print_to_console "processing #{csv_size(:user)} users"
      
      users_bar = ProgressBar.new("Users...", csv_size(:user)) if @verbose

      csv_for_each :user do |row|
        next if row["id"].nil? || row["id"].empty?
        user = User.find_or_initialize_by_email(row["email"])
        if user.new_record?
          user.password_confirmation = row["password"]
          # Needed for CAPTCHA
          user.bypass_humanizer = true

          save_model_with_attributes(user, row)
        end

        # cache user id
        user_ids[row["id"]] = user.id
        users_bar.inc  if @verbose
      end

      users_bar.finish  if @verbose

      print_to_console "processing #{csv_size(:group)} groups"

      groups_bar = ProgressBar.new("Groups...", csv_size(:group))  if @verbose

      # This function will change the header
      # due to a typo, if didn't exec
      # the validator before
      fix_csv_elp_name

      csv_for_each :group do |row|
        group = Group.find_or_initialize_by_name(row["name"])
        save_model_with_attributes(group, row)

        # cache group id
        groups[row["id"]] = group
        groups_bar.inc if @verbose
      end

      groups_bar.finish if @verbose

      print_to_console "processing #{csv_size(:membership)} memberships"

      members_bar = ProgressBar.new("Memberships...", csv_size(:membership)) if @verbose

      csv_for_each :membership do |row|
        next if row["id"].nil? || row["id"].empty?
        group       = groups[row["group_id"]]
        member_id   = user_ids[row["member_id"]]
        membership  = group.memberships.find_or_initialize_by_member_id(member_id) do |m|
          m.creator = User.find(user_ids[row["creator_id"]]) if row["creator_id"].present?
        end
        save_model_with_attributes(membership, row)
        members_bar.inc if @verbose

      end

      members_bar.finish if @verbose

      print_to_console "processing #{csv_size(:ling)} lings"

      lings_bar = ProgressBar.new("Lings...", csv_size(:ling)) if @verbose

      csv_for_each :ling do |row|
        next if row["id"].nil? || row["id"].empty?
        group     = groups[row["group_id"]]
        ling      = group.lings.find_or_initialize_by_name(row["name"]) do |m|
          m.creator = User.find(user_ids[row["creator_id"]]) if row["creator_id"].present?
        end
        save_model_with_attributes(ling, row)

        # cache ling id
        ling_ids[row["id"]] = ling.id
        lings_bar.inc if @verbose
      end

      lings_bar.finish if @verbose

      print_to_console "processing #{csv_size(:ling)} parent/child ling associations"

      ling_associations_bar = ProgressBar.new("Ling Associations...", csv_size(:ling)) if @verbose

      csv_for_each :ling do |row|
        ling_associations_bar.inc if @verbose
        next if row["parent_id"].blank?
        child   = Ling.find(ling_ids[row["id"]])
        parent  = Ling.find(ling_ids[row["parent_id"]])
        child.parent = parent
        child.save!
      end

      ling_associations_bar.finish if @verbose

      print_to_console "processing #{csv_size(:role)} roles"

      roles_bar = ProgressBar.new("Roles...", csv_size(:role)) if @verbose

      csv_for_each :role do |row|

        # Look for the member
        group     = groups[row["group_id"]]
        member_id   = user_ids[row["member_id"]]
        membership  = group.memberships.find_by_member_id(member_id)

        # Look for the language
        language = Ling.find(ling_ids[row["resource_id"]])

        # Now add the role to the member for that language
        membership.add_expertise_in(language) unless language.nil?
        if language.nil?
          puts row["resource_id"] 
          puts ling_ids[row["resource_id"]]
        end

        roles_bar.inc if @verbose
      end

      roles_bar.finish if @verbose

      print_to_console "processing #{csv_size(:category)} categories"

      cats_bar = ProgressBar.new("Categories...", csv_size(:category)) if @verbose

      csv_for_each :category do |row|
        next if row["id"].nil? || row["id"].empty?
        group     = groups[row["group_id"]]
        category  = group.categories.find_or_initialize_by_name(row["name"]) do |m|
          m.creator = User.find(user_ids[row["creator_id"]]) if row["creator_id"].present?
        end
        save_model_with_attributes category, row

        # cache category id
        category_ids[row["id"]] = category.id
        cats_bar.inc if @verbose
      end

      cats_bar.finish if @verbose

      print_to_console "processing #{csv_size(:property)} properties"

      prop_bar = ProgressBar.new("Properties...", csv_size(:property)) if @verbose

      csv_for_each :property do |row|
        next if row["id"].nil? || row["id"].empty?
        group    = groups[row["group_id"]]
        category = group.categories.find(category_ids[row["category_id"]])
        property = group.properties.find_or_initialize_by_name(row["name"]) do |p|
          p.category = category
          p.creator = User.find(user_ids[row["creator_id"]]) if row["creator_id"].present?
        end
        # fix some issues with the description field
        row["description"] = row["description"].nil? ? '' : row["description"].gsub(/\{\}/, ";").gsub(/\[\]/,"\"")
        save_model_with_attributes property, row

        # cache property id
        property_ids[row["id"]] = property.id
        prop_bar.inc if @verbose
      end

      prop_bar.finish if @verbose

      print_to_console "processing #{csv_size(:example)} examples"

      examples_bar = ProgressBar.new("Examples...", csv_size(:example)) if @verbose

      Example.transaction do
        csv_for_each :example do |row|
          next if row["id"].nil? || row["id"].empty?
          group    = groups[row["group_id"]]

          example  = group.examples.find_or_initialize_by_name_and_ling_id(row["name"], ling_ids[row["ling_id"]]) do |e|
            e.creator = User.find(user_ids[row["creator_id"]]) if row["creator_id"].present?
          end
          save_model_with_attributes example, row

          # cache example id
          example_ids[row["id"]] = example.id
          examples_bar.inc if @verbose
        end
      end

      examples_bar.finish if @verbose

      total = csv_size(:lings_property)
      print_to_console "processing #{total} lings_property"

      lings_prop_bar = ProgressBar.new("Lings Property...", total) if @verbose

      LingsProperty.transaction do
        csv_for_each :lings_property do |row|
          next if row["id"].nil? || row["id"].empty?
          group       = groups[row["group_id"]]
          ling_id     = ling_ids[row["ling_id"]]
          value       = row["value"]
          property_id = property_ids[row["property_id"]]

          lp = group.lings_properties.find_or_initialize_by_group_id_and_value_and_ling_id_and_property_id(group.id, value, ling_id, property_id) do |lp|
            lp.creator = User.find(user_ids[row["creator_id"]]) if row["creator_id"].present?
          end

          save_model_with_attributes lp, row

          # cache lings_property id
          lings_property_ids[row["id"]] = lp.id
          lings_prop_bar.inc if @verbose
        end
      end

      lings_prop_bar.finish if @verbose

      print_to_console "processing #{csv_size(:examples_lings_property)} examples_lings_property"

      example_lings_prop_bar = ProgressBar.new("Examples Lings Properties...", csv_size(:examples_lings_property)) if @verbose

      ExamplesLingsProperty.transaction do
        csv_for_each :examples_lings_property do |row|
          next if row["id"].nil? || row["id"].empty?
          group             = groups[row["group_id"]]
          example_id        = example_ids[row["example_id"]]
          lings_property_id = lings_property_ids[row["lings_property_id"]]

          elp = group.examples_lings_properties.find_or_initialize_by_group_id_and_example_id_and_lings_property_id(group.id, example_id, lings_property_id) do |elp|
            elp.creator = User.find(user_ids[row["creator_id"]]) if row["creator_id"].present?
          end

          save_model_with_attributes elp, row

          example_lings_prop_bar.inc if @verbose
        end

      end

      example_lings_prop_bar.finish if @verbose

      print_to_console "processing #{csv_size(:stored_value)} stored value"

      stored_values_bar = ProgressBar.new("Stored Values...", csv_size(:stored_value)) if @verbose

      StoredValue.transaction do
        csv_for_each :stored_value do |row|
          next if row["id"].nil? || row["id"].empty?

          value = row["value"].gsub("#{row["key"]}:", '')
          group         = groups[row["group_id"]]
          storable_type = row['storable_type']
          storable_id   = self.send("#{storable_type.downcase}_ids")[row["storable_id"]]
          # conditions = { :group_id => group.id, :storable_id => storable_id, :storable_type => storable_type,
          #                :key => row["key"], :value => value }

          # group.stored_values.where(conditions).select(:id).first || group.stored_values.create(conditions)
          # group.stored_values.where(conditions).first_or_create(conditions)
          stored = group.stored_values.find_or_initialize_by_group_id_and_storable_id_and_storable_type_and_key_and_value(group.id, storable_id, storable_type, row["key"], value)
          StoredValue.skip_callback(:create)
          stored.save!(:validate => false)
          StoredValue.set_callback(:create)

          stored_values_bar.inc if @verbose
        end
      end

      stored_values_bar.finish if @verbose

      elapsed = seconds_fraction_to_time(Time.now - start)
      print_to_console "Time for import: #{elapsed[0]} : #{elapsed[1]} : #{elapsed[2]}\n"
    end

    private

    def print_to_console(string)
      logger.info string if @verbose
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
      @logger ||= Rails.env.production? ? Logger.new(STDOUT) : Rails.logger
    end
  end
end