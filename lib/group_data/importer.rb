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

require 'readers/CSVReader'
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

      import_csv :user

      # This function will change the header
      # due to a very common typo on csv
      fix_csv_elp_name

      import_csv :group

      import_csv :membership

      import_csv :ling

      import_csv :ling_associations

      import_csv :role

      import_csv :category

      import_csv :property

      import_csv :example

      import_csv :lings_property

      import_csv :examples_lings_property

      import_csv :stored_value

      elapsed = seconds_fraction_to_time(Time.now - start)
      print_to_console "Time for import: #{elapsed[0]} : #{elapsed[1]} : #{elapsed[2]}\n"
    end

    private

    def import_csv method_key
      class_key = extract_class_from_method(method_key)

      #Inizialize a CSVReader to read the right csv
      csv_reader = CSVReader.new(@config[class_key])

      title = method_key.to_s.titleize.pluralize
      total = csv_reader.size

      print_to_console "processing #{total} #{title}"

      progress_bar = ProgressBar.new("#{title}...", total) if @verbose

      #choose which import method to run
      import_method = import_method_factory(method_key)
      #choose which class to use for transaction
      import_class = class_key.to_s.titleize.delete(' ').constantize

      import_class.transaction do
        csv_reader.for_each do |row|

          #run the right import method
          import_method.call(row)

          progress_bar.inc if @verbose
        end
      end

      progress_bar.finish  if @verbose
    end

    def extract_class_from_method method_key
      method_key == :ling_associations ? :ling : method_key
    end

    def import_method_factory key
      #The name of import method is <model>_import_from_csv_row
      method_import = self.method("#{key.to_s}_import_from_csv_row")
      Proc.new { |row| method_import.call(row) }
    end

    ##############################
    # Start list of import methods
    ##############################

    def user_import_from_csv_row row
      if !row["id"].nil? || row["id"].present?
        user = User.find_or_initialize_by_email(row["email"])
        if user.new_record?
          user.password_confirmation = row["password"]
          # Needed for CAPTCHA
          user.bypass_humanizer = true

          save_model_with_attributes(user, row)
        end

        # cache user id
        user_ids[row["id"]] = user.id
      end
    end

    def group_import_from_csv_row row
      group = Group.find_or_initialize_by_name(row["name"])
      save_model_with_attributes(group, row)

      # cache group id
      groups[row["id"]] = group
    end

    def membership_import_from_csv_row row
      if !row["id"].nil? || row["id"].present?
        group       = groups[row["group_id"]]
        member_id   = user_ids[row["member_id"]]
        membership  = group.memberships.find_or_initialize_by_member_id(member_id) do |m|
          m.creator = User.find(user_ids[row["creator_id"]]) if row["creator_id"].present?
        end
        save_model_with_attributes(membership, row)
      end
    end

    def ling_import_from_csv_row row
      if !row["id"].nil? || row["id"].present?
        group     = groups[row["group_id"]]
        ling      = group.lings.find_or_initialize_by_name(row["name"]) do |m|
          m.creator = User.find(user_ids[row["creator_id"]]) if row["creator_id"].present?
        end
        save_model_with_attributes(ling, row)

        # cache ling id
        ling_ids[row["id"]] = ling.id
      end
    end

    def ling_associations_import_from_csv_row row
      if !row["parent_id"].blank?
        child   = Ling.find(ling_ids[row["id"]])
        parent  = Ling.find(ling_ids[row["parent_id"]])
        child.parent = parent
        child.save!
      end
    end

    def role_import_from_csv_row row
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
    end

    def category_import_from_csv_row row
      if !row["id"].nil? || row["id"].present?
        group     = groups[row["group_id"]]
        category  = group.categories.find_or_initialize_by_name(row["name"]) do |m|
          m.creator = User.find(user_ids[row["creator_id"]]) if row["creator_id"].present?
        end
        save_model_with_attributes category, row

        # cache category id
        category_ids[row["id"]] = category.id
      end
    end

    def property_import_from_csv_row row
      if !row["id"].nil? || row["id"].present?
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
      end
    end

    def example_import_from_csv_row row
      if !row["id"].nil? || row["id"].present?
        group    = groups[row["group_id"]]

        example  = group.examples.find_or_initialize_by_name_and_ling_id(row["name"], ling_ids[row["ling_id"]]) do |e|
          e.creator = User.find(user_ids[row["creator_id"]]) if row["creator_id"].present?
        end
        save_model_with_attributes example, row

        # cache example id
        example_ids[row["id"]] = example.id
      end
    end

    def lings_property_import_from_csv_row row
      if !row["id"].nil? || row["id"].present?
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
      end
    end

    def examples_lings_property_import_from_csv_row row
      if !row["id"].nil? || row["id"].present?
        group             = groups[row["group_id"]]
        example_id        = example_ids[row["example_id"]]
        lings_property_id = lings_property_ids[row["lings_property_id"]]

        elp = group.examples_lings_properties.find_or_initialize_by_group_id_and_example_id_and_lings_property_id(group.id, example_id, lings_property_id) do |elp|
          elp.creator = User.find(user_ids[row["creator_id"]]) if row["creator_id"].present?
        end

        save_model_with_attributes elp, row
      end
    end

    def stored_value_import_from_csv_row row
      if !row["id"].nil? || row["id"].present?
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
      end
    end

    ############################
    # End list of import methods
    ############################


    def fix_csv_elp_name
      # Load the CSV file
      file = @config[:group]
      string_fixed = "examples_lings_property_name"
      bad_string = "example_lings_property_name"

      text = File.read(file)
      new_text = text.gsub(/#{bad_string}.*,/, string_fixed)
      File.open(file, "w") {|file| file.puts new_text}
    end

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

    def logger
      @logger ||= Rails.env.production? ? Logger.new(STDOUT) : Rails.logger
    end
  end
end