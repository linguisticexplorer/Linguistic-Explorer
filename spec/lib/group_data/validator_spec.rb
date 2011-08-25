require "spec_helper"

module GroupData

  describe Validator do

    before(:all) do
      # Create fixture CSVs for validation
      generate_group_data_csvs!
    end

    describe "validate!" do
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
        @validator = Validator.validate(@config)
      end

      it "should load configuration from yaml" do
        @validator.config[:lings_property].should == Rails.root.join("spec", "csv", "LingsProperty.csv").to_s
      end

      it "should validate users" do
        @validator.check_users.should == true
      end

      it "should validate groups" do
        @validator.check_groups.should == true
      end

      it "should validate memberships" do
        @validator.check_memberships.should == true
      end

      it "should validate categories" do
        @validator.check_categories.should == true
      end

      it "should validate lings" do
        @validator.check_lings.should == true
      end

      it "should validate examples" do
        @validator.check_examples.should == true
      end

      it "should validate lings properties" do
        @validator.check_lings_properties.should == true
      end

      it "should validate example lings properties" do
        @validator.check_examples_lp.should == true
      end

      it "should validate parent/child ling association" do
        @validator.check_parents.should == true
      end

      it "should validate stored values" do
        @validator.check_stored_values.should == true
      end

      it "should have happy ending" do
        @validator.check_all.should == true
      end
    end


  end

end