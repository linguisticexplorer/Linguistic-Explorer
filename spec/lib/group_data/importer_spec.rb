require 'spec_helper'

module GroupData

  describe Importer do

    before(:all) do
      # Create fixture CSVs for import
      generate_group_data_csvs!
    end

    describe "import!" do
      before(:each) do
        config = {}.tap do |paths|
          [:user,
          :category,
          :example,
          :examples_lings_property,
          :group,
          :ling,
          :lings_property,
          :membership,
          :property,
          :stored_value].each do |model|
            paths[model.to_s] = Rails.root.join("spec", "csv", "good","#{model.to_s.camelize}.csv").to_s
          end
        end
        File.open(Rails.root.join("spec", "csv", "good","import.yml"), "wb") { |f| f.write config.to_yaml }

        @config   = YAML.load_file(Rails.root.join("spec", "csv", "good","import.yml"))
        @importer = Importer.import(@config)
        @current_group = Group.find_by_name(@group.name)
      end

      it "should load configuration from yaml" do
        @importer.config[:ling].should == Rails.root.join("spec", "csv", "good","Ling.csv").to_s
      end

      it "should import group" do
        attributes_should_match(@current_group, @group)
      end

      it "should parse example fields" do
        @current_group.example_storable_keys.should == ["text", "words", "gloss"]
      end

      it "should cache groups" do
        @importer.groups.values.first.id.should == @current_group.id
      end

      it "should import users" do
        @users.each do |user|
          imported = User.find_by_name(user.name)
          attributes_should_match(imported, user, :except => :password)
        end
      end

      it "should cache user ids" do
        @importer.user_ids.values.first.should == User.find_by_name(@users.first.name).id
      end

      it "should import memberships" do
        @current_group.memberships.size.should == @memberships.size
        @users.each_with_index do |user, i|
          imported_user = User.find_by_name(user.name)
          imported  = @current_group.membership_for(imported_user)

          attributes_should_match(imported, @memberships[i])
          imported.creator.name.should == @admin.name
        end
      end

      it "should import lings" do
        @current_group.lings.size.should == @lings.size
        @lings.each_with_index do |ling|
          imported = Ling.find_by_name(ling.name)
          attributes_should_match(imported, ling)
          imported.creator.name.should == @admin.name
        end
      end

      it "should associate child lings with parent lings" do
        children = @current_group.lings.where('parent_id IS NOT NULL')
        children.size.should == 2
        children.map(&:parent).compact.size.should == 2
      end

      it "should import properties" do
        @current_group.properties.size.should == @properties.size
        @properties.each do |property|
          imported = @current_group.properties.find_by_name(property.name)
          imported.category.should be_present
          attributes_should_match imported, property
          imported.creator.name.should == @admin.name
        end
      end

      it "should import categories" do
        @current_group.categories.size.should == @categories.size
        @categories.each do |category|
          imported = @current_group.categories.find_by_name(category.name)
          attributes_should_match imported, category
          imported.creator.name.should == @admin.name
        end
      end

      it "should import examples" do
        @current_group.examples.size.should == @examples.size
        @examples.each do |example|
          imported = @current_group.examples.find_by_name(example.name)
          attributes_should_match imported, example
          imported.creator.name.should == @admin.name
        end
      end

      it "should import lings_properties" do
        @current_group.lings_properties.size.should == @lings_properties.size
        @lings_properties.each do |lings_property|
          imported = @current_group.lings_properties.where(:value => lings_property.value).first
          attributes_should_match imported, lings_property
          imported.creator.name.should == @admin.name
        end
      end

      it "should import examples_lings_properties" do
        @current_group.examples_lings_properties.size.should == @examples_lings_properties.size
        @examples.each do |example|
          imported_example = @current_group.examples.find_by_name(example.name)
          imported = @current_group.examples_lings_properties.detect { |elp| elp.example_id == imported_example.id }
          imported.should be_present
          imported.creator.name.should == @admin.name
        end
      end

      it "should import stored_values" do
        @current_group.stored_values.size.should == @stored_values.size
        @stored_values.each do |sv|
          imported = @current_group.stored_values.find_by_value(sv.value)
          attributes_should_match imported, sv
        end
      end

    end

    describe "csv generation" do
      it "should have cleaned the db" do
        Group.find_by_name(@group.name).should be_nil
      end
      it "should have the correct number of csv rows to import" do
        @group_data.each do |models|
          csv_row_count_should_equal_count_of(*models)
        end
      end
      it "should have the correct number of csv data sets to import" do
        data_sets_size = 10
        @group_data.size.should == data_sets_size
      end
    end

    def attributes_should_match(imported, source, opts = {})
      imported.should be_present
      attributes = source.class.importable_attributes - [opts[:except]].flatten.compact.map(&:to_s)
      attributes.each do |attribute|
        imported.send(attribute).should == source.send(attribute)
      end
    end

  end
end
