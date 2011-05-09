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
            paths[model.to_s] = Rails.root.join("spec", "csv", "#{model.to_s.camelize}.csv").to_s
          end
        end
        File.open(Rails.root.join("spec", "csv", "import.yml"), "wb") { |f| f.write config.to_yaml }

        @config   = YAML.load_file(Rails.root.join("spec", "csv", "import.yml"))
        @importer = Importer.import(@config)
        @current_group = Group.find_by_name(@group.name)
      end

      it "should load configuration from yaml" do
        @importer.config[:ling].should == Rails.root.join("spec", "csv", "Ling.csv").to_s
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
        end
      end

      it "should import lings" do
        @current_group.lings.size.should == @lings.size
        @lings.each_with_index do |ling|
          imported = Ling.find_by_name(ling.name)
          attributes_should_match(imported, ling)
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
        end
      end

      it "should import categories" do
        @current_group.categories.size.should == @categories.size
        @categories.each do |category|
          imported = @current_group.categories.find_by_name(category.name)
          attributes_should_match imported, category
        end
      end

      it "should import examples" do
        @current_group.examples.size.should == @examples.size
        @examples.each do |example|
          imported = @current_group.examples.find_by_name(example.name)
          attributes_should_match imported, example
        end
      end

      it "should import lings_properties" do
        @current_group.lings_properties.size.should == @lings_properties.size
        @lings_properties.each do |lings_property|
          imported = @current_group.lings_properties.where(:value => lings_property.value).first
          attributes_should_match imported, lings_property
        end
      end

      it "should import examples_lings_properties" do
        @current_group.examples_lings_properties.size.should == @examples_lings_properties.size
        @examples.each do |example|
          imported_example = @current_group.examples.find_by_name(example.name)
          elp = @current_group.examples_lings_properties.select { |elp| elp.example_id == imported_example.id }
          elp.should be_present
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

    def generate_group_data_csvs!
      # Create users
      @users = [].tap do |models|
        User::ACCESS_LEVELS.each do |al|
          models << Factory(:user, :name => "Bob #{al.capitalize}", :email => "bob#{al}@example.com",
            :access_level => al, :password => "password_#{al}")
        end
      end
      @admin  = @users.first
      @user   = @users.last

      # Group
      @group  = Factory(:group, :name => "SSWL", :privacy => Group::PRIVATE,
        :depth_maximum => 1, :ling0_name => "Language", :ling1_name => "Speaker",
        :property_name => "Grammar", :category_name => "Demographic",
        :lings_property_name => "Value", :example_name => "Quotes",
        :examples_lings_property_name => "Quote Values", :example_fields => "words, gloss")

      # Memberships
      @memberships = [].tap do |models|
        models << Factory(:membership, :group => @group, :member => @admin, :level => Membership::ADMIN, :creator => @admin)
        models << Factory(:membership, :group => @group, :member => @user, :level => Membership::MEMBER, :creator => @admin)
      end

      # Parent Lings
      @lings = [].tap do |models|
        2.times do |i|
          models << Factory(:ling, :group => @group, :name => "Parent #{i}", :depth => Depth::PARENT, :creator => @admin)
        end
      end

      # Child Lings
      @lings += [].tap do |models|
        @lings.each_with_index do |parent, i|
          models << Factory(:ling,
            :group => @group, :name => "Child #{i}", :depth => Depth::CHILD, :creator => @admin, :parent => parent)
        end
      end

      # Categories
      @categories = [].tap do |models|
        { :parent => Depth::PARENT, :child => Depth::CHILD }.each do |k, depth|
          models << Factory(:category, :group => @group, :creator => @admin,
            :name => "#{k.capitalize} Category", :depth => depth, :description=> "This is the #{k} category")
        end
      end

      # Examples, 1 for each ling
      @examples = [].tap do |models|
        @lings.each_with_index do |ling, i|
          models << Factory(:example, :ling => ling, :name => "Example #{i}", :group => @group, :creator => @admin)
        end
      end

      #
      @properties = [].tap do |models|
        @lings.each_with_index do |ling, i|
          models << Factory(:property, :name => "Property #{i}", :description => "This is property #{i}",
            :group => @group, :creator => @admin, :category => @categories.detect { |c| c.depth == ling.depth })
        end
      end

      @lings_properties = [].tap do |models|
        @lings.each_with_index do |ling, i|
          models << Factory(:lings_property, :ling => ling, :property => @properties[i], :value => "Value #{i}",
            :group => @group, :creator => @admin)
        end
      end

      @examples_lings_properties = [].tap do |models|
        @examples.each_with_index do |example, i|
          models << Factory(:examples_lings_property, :example => example,
            :lings_property => @lings_properties[i], :group => @group, :creator => @admin)
        end
      end

      @stored_values = [].tap do |models|
        @examples.each do |example|
          models << Factory(:stored_value, :storable => example, :group => @group,
            :key => "words", :value => "#{example.name} blah blah blah")
        end
        @examples.each do |example|
          models << Factory(:stored_value, :storable => example, :group => @group,
            :key => "gloss", :value => "#{example.name} gloss")
        end
      end

      # Transfer model data to csv and destroy so we can test import of data
      @group_data = [@users, [@group], @memberships, @examples, @lings, @categories,
        @properties, @lings_properties, @examples_lings_properties, @stored_values]

      @group_data.each do |models|
        generate_csv_and_destroy_records(*models)
      end
    end
  end
end
