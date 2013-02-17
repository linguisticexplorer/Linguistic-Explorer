require 'spec_helper'

describe Example do
  describe "one-liners" do
    it { should validate_presence_of :group }
    it { should belong_to :ling }
    it { should belong_to :group }
    it { should belong_to :creator }
    it { should have_many :examples_lings_properties }
    it { should have_many :lings_properties }
    # it_should_validate_presence_of :group
    # it_should_belong_to :ling, :group, :creator
    # it_should_have_many :examples_lings_properties, :lings_properties
  end

  describe "should be createable" do
    it "with a ling and that ling's group id" do
      ling = lings(:level0)
      lambda do
        Example.create(:ling_id => ling.id, :name => 'example-with-ling_id') do |e|
          e.group = ling.group
        end
      end.should change(Example, :count).by(1)
    end

    it "unless the ling and group_id don't match" do
      ling = groups(:inclusive).lings.first
      group = groups(:exclusive)
      Example.create(:ling_id => ling.id, :name => 'example-with-mismatched-object-refs') do |e|
        e.group = group
      end.should have(1).error_on(:ling)
    end

    it "without a ling" do
      lambda do
        Example.create(:name => 'example-without-ling_id') do |e|
          e.group = groups(:inclusive)
        end
      end.should change(Example, :count).by(1)
    end
  end

  describe "#grouped_name" do
    it "should return the Example name from its associated group" do
      example = examples(:inclusive)
      example.group.example_name.should == example.grouped_name
    end
  end

  describe "StoredValues" do
    # it_should_have_many :stored_values
    it { should have_many :stored_values }

    describe "#storable_keys" do
      it "should return the associated group's example_storable_keys value if group is present" do
        group = groups(:inclusive)
        Example.create(:group => group).storable_keys.should == group.example_storable_keys
      end

      it "should return the an empty array if group is not present" do
        Example.create.storable_keys.should == []
      end
    end

    describe "#stored_value" do
      it "should default available but unset keys to an empty string" do
        example = examples(:valueless)
        example.storable_keys.should include "description"
        example.stored_value(:description).should == ""
      end

      it "should return the value of in the associated StoredValue record if there is one" do
        example = examples(:inclusive)
        example.storable_keys.should include "description"
        StoredValue.find_by_group_id_and_key(example.group.id, "description").should be_nil
        StoredValue.create(:storable => example, :key => "description", :value => "awesome")
        example.reload.stored_value(:description).should == "awesome"
      end

      it "should return nil if the key is invalid" do
        example = examples(:inclusive)
        example.storable_keys.should_not include "totallyfake"
        example.stored_value("totallyfake").should be_nil
      end
    end

    describe "#store_value!" do
      it "should store the value for a valid key" do
        ling = lings(:level0)
        group = ling.group
        example = Example.create(:ling_id => ling.id, :name => 'has-text') do |e|
          e.group = group
        end
        example.storable_keys.should include "description"
        example.store_value!(:description, "foo")
        example.reload.stored_value(:description).should == "foo"
      end

      it "should have be able to update the value" do
        ling = lings(:level0)
        group = ling.group
        example = Example.create(:ling_id => ling.id, :name => 'has-text') do |e|
          e.group = group
        end
        example.storable_keys.should include "description"
        example.store_value!(:description, "foo")
        example.reload.stored_value(:description).should == "foo"

        example.store_value!(:description, "bar")
        example.reload.stored_value(:description).should == "bar"
      end

      it "should have be able to store a value for a key supplied by the group" do
        ling = lings(:level0)
        group = ling.group
        group.example_fields = "custom_key"
        group.save
        group.reload

        key = group.example_storable_keys.last
        key.should == "custom_key"
        Group::DEFAULT_EXAMPLE_KEYS.should_not include key

        example = Example.create(:ling_id => ling.id, :name => 'has-text') do |e|
          e.group = group
        end

        example.storable_keys.should include key.to_s
        example.store_value!(key, "baz")
        example.stored_value(key).should == "baz"
      end

      it "should not save the value passed or report errors on the key name for unrecognized keys" do
        ling = lings(:level0)
        group = ling.group
        example = Example.create(:ling_id => ling.id, :name => 'has-text') do |e|
          e.group = group
        end
        example.storable_keys.should_not include "totallyfake"
        example.store_value!(:totallyfake, "bar")
        example.reload.stored_value(:totallyfake).should be_nil
      end
    end
  end
end
