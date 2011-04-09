require 'spec_helper'

describe Example do
  describe "one-liners" do
    it_should_validate_presence_of :group
    it_should_belong_to :ling, :group, :creator
    it_should_have_many :examples_lings_properties, :lings_properties
#    should_validate_existence_of :group  #TODO these tests dont really work as provided...
#    should_validate_existence_of :creator
#    should_validate_existence_of :ling, :allow_nil => true
  end

  describe "should be createable" do
    it "with a ling and that ling's group id" do
      ling = lings(:level0)
      should_be_createable :with => { :ling_id => ling.id, :group_id => ling.group.id, :name => 'example-with-ling_id' }
    end

    it "unless the ling and group_id don't match" do
      ling = groups(:inclusive).lings.first
      group = groups(:exclusive)
      Example.create(:ling_id => ling.id, :group_id => group.id, :name => 'example-with-mismatched-object-refs').should have(1).error_on(:ling)
    end

    it "without a ling" do
      should_be_createable :with => {:name => 'example-without-ling_id', :group_id => Group.first.id }
    end
  end

  describe "#grouped_name" do
    it "should return the Example name from its associated group" do
      example = examples(:inclusive)
      example.group.example_name.should == example.grouped_name
    end
  end

  describe "StoredValues" do
    it_should_have_many :stored_values

    describe "#storable_keys" do
      it "should always have the key 'text'" do
        Example.create.storable_keys.should include 'text'
      end

#    it "should have any any key available to examples in the group" do
#      group = groups(:inclusive)
#      group.example_keys.should_not be_empty
#      example = examples(:inclusive)
#      group.example_keys.each{ |key| example.storable_keys.should include key }
#    end
    end

    describe "#stored_value" do
      it "should default available but unset keys to an empty string" do
        example = examples(:valueless)
        example.storable_keys.should include "text"
        StoredValue.find_by_group_id_and_key(example.group.id, "text").should be_nil
        example.stored_value(:text).should == ""
      end

      it "should return the value of in the associated StoredValue record if there is one" do
        example = examples(:inclusive)
        example.storable_keys.should include "text"
        StoredValue.find_by_group_id_and_key(example.group.id, "text").should be_nil
        StoredValue.create(:storable => example, :key => "text", :value => "awesome")
        example.reload.stored_value(:text).should == "awesome"
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
        example = Example.create(:ling_id => ling.id, :group_id => group.id, :name => 'has-text')
        example.storable_keys.should include "text"
        example.store_value!(:text, "foo")
        example.reload.stored_value(:text).should == "foo"
      end

      it "should have be able to update the value" do
        ling = lings(:level0)
        group = ling.group
        example = Example.create(:ling_id => ling.id, :group_id => group.id, :name => 'has-text')
        example.storable_keys.should include "text"
        example.store_value!(:text, "foo")
        example.reload.stored_value(:text).should == "foo"

        example.store_value!(:text, "bar")
        example.reload.stored_value(:text).should == "bar"
      end

#    it "should have be able to store a value for a key supplied by the group" do
#      ling = lings(:level0)
#      group = ling.group
#      group.storable_keys_for(:example).should_not be_empty
#      key = group_storable_keys_for(:example).first
#      example = Example.create(:ling_id => ling.id, :group_id => group.id, :name => 'has-text')
#      example.storable_keys.should include key.to_s
#      example.store_value!(key, "baz")
#      example.stored_value(key).should == "baz"
#    end

      it "should not save the value passed or report errors on the keyname for unrecognized keys" do
        ling = lings(:level0)
        group = ling.group
        example = Example.create(:ling_id => ling.id, :group_id => group.id, :name => 'has-text')
        example.storable_keys.should_not include "totallyfake"
        example.store_value!(:totallyfake, "bar")
        example.reload.stored_value(:totallyfake).should be_nil
      end
    end
  end
end
