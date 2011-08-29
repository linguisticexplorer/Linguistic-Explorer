require "spec_helper"

module GroupData

  describe Validator do

    before(:all) do
      # Create fixture CSVs for validation
      generate_group_data_csvs!
    end

    describe "validate! success" do

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
        @validator = Validator.load(@config)
        @validator.validate!
      end

      it "should load configuration from yaml" do
        @validator.config[:lings_property].should == Rails.root.join("spec", "csv", "good","LingsProperty.csv").to_s
      end

      it "should validate users" do
        @validator.check_users.should be_true
      end

      it "should validate groups" do
        @validator.check_groups.should be_true
      end

      it "should validate memberships" do
        @validator.check_memberships.should be_true
      end

      it "should validate categories" do
        @validator.check_categories.should be_true
      end

      it "should validate lings" do
        @validator.check_lings.should be_true
      end

      it "should validate examples" do
        @validator.check_examples.should be_true
      end

      it "should validate lings properties" do
        @validator.check_lings_properties.should be_true
      end

      it "should validate example lings properties" do
        @validator.check_examples_lp.should be_true
      end

      it "should validate parent/child ling association" do
        @validator.check_parents.should be_true
      end

      it "should validate stored values" do
        @validator.check_stored_values.should be_true
      end

      it "should have happy ending" do
        @validator.check_all.should be_true
      end
    end

    describe "validate! fail (no ID field)" do

      before(:all) do
        # Create fixture CSVs for validation
        generate_bad_csv_from_good_ones! "no_id"
        @count = {:count => 0}
      end

      before(:each) do
        load_config "no_id"

        @config   = YAML.load_file(Rails.root.join("spec", "csv", "bad" , "no_id", "import.yml"))
        @validator = Validator.load(@config)
        begin
          @validator.validate!
        rescue SystemExit
        end
      end

      after(:each) do
        # Trick to have a counter between tests
        @count[:count] += 1
      end

      after(:all) do
        @count[:count] = 0
      end

      it "should exit on users check" do
        @validator.check_users.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on groups check" do
        @validator.check_users.should be_true
        @validator.check_groups.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on memberships check" do
        @validator.check_users.should be_true
        @validator.check_memberships.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on category check" do
        @validator.check_users.should be_true
        @validator.check_categories.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on ling check" do
        @validator.check_users.should be_true
        @validator.check_lings.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on examples check" do
        @validator.check_users.should be_true
        @validator.check_examples.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on examples lings properties check" do
        @validator.check_users.should be_true
        @validator.check_examples_lp.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on lings properties check" do
        @validator.check_users.should be_true
        @validator.check_lings_properties.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on properties check" do
        @validator.check_users.should be_true
        @validator.check_properties.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on stored values check" do
        @validator.check_users.should be_true
        @validator.check_stored_values.should be_false
        @validator.check_all.should be_false
      end
    end

    describe "validate! fail (bad foreign key)" do

      before(:all) do
        # Create fixture CSVs for validation
        generate_bad_csv_from_good_ones! "bad_foreign_key"
        @count = {:count => 2} # Skip Users & Groups
      end

      before(:each) do
        load_config "bad_foreign_key"

        @config   = YAML.load_file(Rails.root.join("spec", "csv", "bad" , "bad_foreign_key", "import.yml"))
        @validator = Validator.load(@config)
        begin
          @validator.validate!
        rescue SystemExit
        end
      end

      after(:each) do
        # Trick to have a counter between tests
        @count[:count] += 1
      end

      after(:all) do
        @count[:count] = 0
      end

      it "should exit on memberships check" do
        @validator.check_users.should be_true
        @validator.check_memberships.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on category check" do
        @validator.check_users.should be_true
        @validator.check_categories.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on ling check" do
        @validator.check_users.should be_true
        @validator.check_lings.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on examples check" do
        @validator.check_users.should be_true
        @validator.check_examples.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on examples lings properties check" do
        @validator.check_users.should be_true
        @validator.check_examples_lp.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on lings properties check" do
        @validator.check_users.should be_true
        @validator.check_lings_properties.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on properties check" do
        @validator.check_users.should be_true
        @validator.check_properties.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on stored values check" do
        @validator.check_users.should be_true
        @validator.check_stored_values.should be_false
        @validator.check_all.should be_false
      end
    end

    describe "validate! fail (bad creator_id)" do

      before(:all) do
        # Create fixture CSVs for validation
        generate_bad_csv_from_good_ones! "bad_creator_id"
        @count = {:count => 2} # Skip Users & Groups
      end

      before(:each) do
        load_config "bad_creator_id"

        @config   = YAML.load_file(Rails.root.join("spec", "csv", "bad" , "bad_creator_id", "import.yml"))
        @validator = Validator.load(@config)
        begin
          @validator.validate!
        rescue SystemExit
        end
      end

      after(:each) do
        # Trick to have a counter between tests
        @count[:count] += 1
      end

      after(:all) do
        @count[:count] = 0
      end

      it "should exit on memberships check" do
        @validator.check_users.should be_true
        @validator.check_memberships.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on category check" do
        @validator.check_users.should be_true
        @validator.check_categories.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on ling check" do
        @validator.check_users.should be_true
        @validator.check_lings.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on examples check" do
        @validator.check_users.should be_true
        @validator.check_examples.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on examples lings properties check" do
        @validator.check_users.should be_true
        @validator.check_examples_lp.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on lings properties check" do
        @validator.check_users.should be_true
        @validator.check_lings_properties.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

      it "should exit on properties check" do
        @validator.check_users.should be_true
        @validator.check_properties.should be_false
        @validator.check_all.should be_false
        @validator.check_stored_values.should be_nil
      end

    end

    describe "bad csv generation" do

      before(:all) do
        @paths = ["no_id", "bad_foreign_key", "bad_creator_id"]
        @paths.each do |path|
          generate_bad_csv_from_good_ones! path
        end
      end

      it "should have created csvs without id" do
        csvs_should_have_no_id
      end

      it "should have created csvs with wrong foreign key" do
        csvs_should_have_wrong_foreign_key "group_id"
      end

      it "should have created csvs with wrong creator_id" do
        csvs_should_have_wrong_foreign_key "creator_id"
      end

      def csvs_should_have_no_id
        files = File.join(Rails.root.join("spec", "csv", "bad", "no_id"), "*.csv")
        Dir.glob(files).each do |file|
          CSV.foreach(file, :headers => true) do |row|
            row[0].should be_nil
          end
        end
      end

      def csvs_should_have_wrong_foreign_key(field_name)
        dir = "bad_creator_id"
        dir = "bad_foreign_key" if field_name == "group_id"
        files = File.join(Rails.root.join("spec", "csv", "bad", dir), "*.csv")
        Dir.glob(files).each do |file|
          CSV.foreach(file, :headers => true) do |row|
            row.each do |field|
              field.should =~ [field_name, "-1"] if field[0]==field_name
            end
          end
        end
      end

    end

    def load_config(dir)
      i = 0
      config = {}.tap do |paths|
        # The Hash should be in order to pass tests
        [:user,
         :group,
         :membership,
         :category,
         :ling,
         :example,
         :examples_lings_property,
         :lings_property,
         :property,
         :stored_value].each do |model|
          paths[model.to_s] = Rails.root.join("spec", "csv", "good", "#{model.to_s.camelize}.csv").to_s unless @count[:count] == i
          paths[model.to_s] = Rails.root.join("spec", "csv", "bad", dir, "#{model.to_s.camelize}.csv").to_s if @count[:count] == i
          i += 1
        end
      end
      File.open(Rails.root.join("spec", "csv", "bad", dir, "import.yml"), "wb") { |f| f.write config.to_yaml }
    end
  end

end