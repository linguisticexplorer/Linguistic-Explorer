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

module GroupData
  class Importer

    class << self
      def import(path)
        importer = new(path)
        importer.import!
        importer
      end
    end

    attr_accessor :config

    # accepts path to yaml file containing paths to csvs
    def initialize(path)
      @path = path
      @config = YAML.load_file(@path)
      @config.symbolize_keys!
    end

    def groups
      @groups ||= {}
    end

    def user_ids
      @user_ids ||= {}
    end

    def ling_ids
      @ling_ids ||= {}
    end

    def category_ids
      @category_ids ||= {}
    end

    def property_ids
      @property_ids ||= {}
    end

    def import!
      # processing groups
      csv_for_each :group do |row|
        group = Group.find_or_initialize_by_name(row["name"])
        save_model_with_attributes(group, row)

        # cache group id
        groups[row["id"]] = group
      end

      # processing users
      csv_for_each :user do |row|
        user = User.find_or_initialize_by_email(row["email"])
        if user.new_record?
          user.password_confirmation = row["password"]
          save_model_with_attributes(user, row)
        end

        # cache user id
        user_ids[row["id"]] = user.id
      end

      # processing memberships
      csv_for_each :membership do |row|
        group       = groups[row["group_id"]]
        member_id   = user_ids[row["member_id"]]
        membership  = group.memberships.find_or_initialize_by_member_id(member_id)
        save_model_with_attributes(membership, row)
      end

      # processing lings
      csv_for_each :ling do |row|
        group     = groups[row["group_id"]]
        ling      = group.lings.find_or_initialize_by_name(row["name"])
        save_model_with_attributes(ling, row)

        # cache ling id
        ling_ids[row["id"]] = ling.id
      end

      # parent/child ling associations
      csv_for_each :ling do |row|
        next if row["parent_id"].blank?
        child   = Ling.find(ling_ids[row["id"]])
        parent  = Ling.find(ling_ids[row["parent_id"]])
        child.parent = parent
        child.save!
      end

      # processing categories
      csv_for_each :category do |row|
        group     = groups[row["group_id"]]
        category  = group.categories.find_or_initialize_by_name(row["name"])
        save_model_with_attributes category, row

        # cache category id
        category_ids[row["id"]] = category.id
      end

      # processing properties
      csv_for_each :property do |row|
        group    = groups[row["group_id"]]
        category = group.categories.find(category_ids[row["category_id"]])
        property = group.properties.find_or_initialize_by_name(row["name"]) do |p|
          p.category = category
        end
        save_model_with_attributes property, row

        # cache property id
        property_ids[row["id"]] = property.id
      end

      # processing examples
      csv_for_each :example do |row|
        group    = groups[row["group_id"]]
        ling     = Ling.find(ling_ids[row["ling_id"]])
        example  = group.examples.find_or_initialize_by_name(row["name"]) do |e|
          e.ling = ling
        end
        save_model_with_attributes example, row
      end

      csv_for_each :lings_property do |row|
        group       = groups[row["group_id"]]
        ling_id     = ling_ids[row["ling_id"]]
        value       = row["value"]
        property_id = property_ids[row["property_id"]]
        conditions  = { :value => value, :ling_id => ling_id, :property_id => property_id }

        next if group.lings_properties.exists?(conditions)
        group.lings_properties.create(conditions)
      end
    end

    private

    def save_model_with_attributes(model, row)
      model.class.importable_attributes.each do |attribute|
        model.send("#{attribute}=", row[attribute])
      end
      model.save!
    end

    def csv_for_each(key)
      CSV.foreach(@config[key], :headers => true) do |row|
        yield(row)
      end
    end
  end

end