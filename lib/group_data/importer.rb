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
# id,name,description,category,group_id,creator_id
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

    def group_ids
      @group_ids ||= {}
    end

    def user_ids
      @user_ids ||= {}
    end

    def ling_ids
      @ling_ids ||= {}
    end

    def import!
      # processing groups
      csv_for_each :group do |row|
        group = Group.find_or_initialize_by_name(row["name"])
        update_csv_row_attributes_on(group, row)
        group_ids[row["id"]] = group.id
      end

      # processing users
      csv_for_each :user do |row|
        user = User.find_or_initialize_by_email(row["email"])
        if user.new_record?
          user.password_confirmation = row["password"]
          update_csv_row_attributes_on(user, row)
        end
        user_ids[row["id"]] = user.id
      end

      # processing memberships
      csv_for_each :membership do |row|
        group_id  = group_ids[row["group_id"]]
        member_id = user_ids[row["member_id"]]
        membership = Membership.find_or_initialize_by_group_id_and_member_id(group_id, member_id)
        update_csv_row_attributes_on(membership, row)
      end

      # processing lings
      csv_for_each :ling do |row|
        group_id  = group_ids[row["group_id"]]
        ling      = Ling.find_or_initialize_by_group_id_and_name(group_id, row["name"])
        update_csv_row_attributes_on(ling, row)
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
    end

    private

    def update_csv_row_attributes_on(model, row)
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