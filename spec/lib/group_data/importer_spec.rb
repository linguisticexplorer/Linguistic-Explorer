require 'rails_helper'

module GroupData

  describe Importer do

    before(:all) do
      # Create fixture CSVs for import
      generate_group_data_csvs!
    end

    after(:all) do
      clean_group_data_csvs!
    end

    describe "import!" do
      before(:each) do
        @config = {}.tap do |paths|
          [:user,
          :category,
          :example,
          :examples_lings_property,
          :group,
          :ling,
          :lings_property,
          :membership,
          :role,
          :property,
          :stored_value].each do |model|
            paths[model.to_s] = Rails.root.join("spec", "csv", "good","#{model.to_s.camelize}.csv").to_s
          end
        end

        @importer = Importer.import(@config, false)
        @current_group = Group.find_by_name(@group.name)
      end

      it "should load configuration from yaml" do
        expect(@importer.config[:ling]).to eq Rails.root.join("spec", "csv", "good","Ling.csv").to_s
      end

      it "should import group" do
        attributes_should_match(@current_group, @group)
      end

      it "should parse example fields" do
        expect(@current_group.example_storable_keys).to eq [ "description", "words", "gloss"]
      end

      it "should cache groups" do
        expect(@importer.groups.values.first.id).to eq @current_group.id
      end

      it "should import users" do
        @users.each do |user|
          imported = User.find_by_name(user.name)
          attributes_should_match(imported, user, :except => :password)
        end
      end

      it "should cache user ids" do
        expect(@importer.user_ids.values.first).to eq User.find_by_name(@users.first.name).id
      end

      it "should import memberships" do
        expect(@current_group.memberships.size).to eq @memberships.size
        @users.each_with_index do |user, i|
          imported_user = User.find_by_name(user.name)
          imported  = @current_group.membership_for(imported_user)

          attributes_should_match(imported, @memberships[i])
          expect(imported.creator.name).to eq @admin.name
        end
      end

      it "should import lings" do
        expect(@current_group.lings.size).to eq @lings.size
        @lings.each_with_index do |ling|
          imported = Ling.find_by_name(ling.name)
          attributes_should_match(imported, ling)
          expect(imported.creator.name).to eq @admin.name
        end
      end

      it "should associate child lings with parent lings" do
        children = @current_group.lings.where('parent_id IS NOT NULL')
        expect(children.size).to eq 2
        expect(children.map(&:parent).compact.size).to eq 2
      end

      it "should import properties" do
        expect(@current_group.properties.size).to eq @properties.size
        @properties.each do |property|
          imported = @current_group.properties.find_by_name(property.name)
          expect(imported.category).to be_present
          attributes_should_match imported, property
          expect(imported.creator.name).to eq @admin.name
        end
      end

      it "should import categories" do
        expect(@current_group.categories.size).to eq @categories.size
        @categories.each do |category|
          imported = @current_group.categories.find_by_name(category.name)
          attributes_should_match imported, category
          expect(imported.creator.name).to eq @admin.name
        end
      end

      it "should import examples" do
        expect(@current_group.examples.size).to eq @examples.size
        @examples.each do |example|
          imported = @current_group.examples.find_by_name(example.name)
          attributes_should_match imported, example
          expect(imported.creator.name).to eq @admin.name
        end
      end

      it "should import lings_properties" do
        expect(@current_group.lings_properties.size).to eq @lings_properties.size
        @lings_properties.each do |lings_property|
          imported = @current_group.lings_properties.where(:value => lings_property.value).first
          attributes_should_match imported, lings_property
          expect(imported.creator.name).to eq @admin.name
        end
      end

      it "should import examples_lings_properties" do
        expect(@current_group.examples_lings_properties.size).to eq @examples_lings_properties.size
        @examples.each do |example|
          imported_example = @current_group.examples.find_by_name(example.name)
          imported = @current_group.examples_lings_properties.detect { |elp| elp.example_id == imported_example.id }
          expect(imported).to be_present
          expect(imported.creator.name).to eq @admin.name
        end
      end

      it "should import stored_values" do
        expect(@current_group.stored_values.size).to eq @stored_values.size
        @stored_values.each do |sv|
          imported = @current_group.stored_values.find_by_value(sv.value)
          attributes_should_match imported, sv
        end
      end

    end

    describe "csv generation" do
      it "should have cleaned the db" do
        expect(Group.find_by_name(@group.name)).to be_nil
      end
      it "should have the correct number of csv rows to import" do
        @group_data.each do |models|
          csv_row_count_should_equal_count_of(*models)
        end
      end
      it "should have the correct number of csv data sets to import" do
        data_sets_size = 10
        expect(@group_data.size).to eq data_sets_size
      end
    end

    def attributes_should_match(imported, source, opts = {})
      expect(imported).to be_present
      attributes = source.class.importable_attributes - [opts[:except]].flatten.compact.map(&:to_s)
      attributes.each do |attribute|
        expect(imported.send(attribute)).to eq source.send(attribute)
      end
    end

  end
end
