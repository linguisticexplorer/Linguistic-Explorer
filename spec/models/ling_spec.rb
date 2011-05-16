require 'spec_helper'

describe Ling do
  describe "one-liners" do
    it_should_validate_presence_of :name, :depth, :group
    it_should_validate_uniqueness_of :name, :scope => :group_id
    it_should_validate_numericality_of :depth

    it_should_have_many :examples, :children, :lings_properties, :children
    it_should_belong_to :parent, :group, :creator
  end

  describe "createable with combinations" do
    it "should allow depth of 0 or 1 with nil parent_id" do
      lambda do
        Ling.create(:parent_id => nil, :name => 'toes') do |ling|
          ling.group = groups(:inclusive)
          ling.depth = 0
        end
      end.should change(Ling, :count).by(1)

      lambda do
        Ling.create(:parent_id => nil, :name => 'twinkle') do |ling|
          ling.group = groups(:inclusive)
          ling.depth = 1
        end
      end.should change(Ling, :count).by(1)
    end

    it "should allow depth 1 lings to have depth 0 parents" do
      parent = lings(:level0)
      lambda do
        Ling.create(:parent_id => parent.id, :name => 'snarfblat') do |ling|
          ling.group = parent.group
          ling.depth = 1
        end
      end.should change(Ling, :count).by(1)
    end

    it "should not allow ling to belong to a different group" do
      ling = groups(:inclusive).lings.select{|l| l.depth == 0}.first
      group = groups(:exclusive)
      Ling.create(:name => "misgrouped", :parent_id => ling.id) do |l|
        l.group = group
        l.depth = 1
      end.should have(1).errors_on(:parent)
    end

    it "should not allow ling creation of a depth greater than the group maximum" do
      group = Factory(:group, :depth_maximum => 0)
      group.depth_maximum.should == 0
      parent = Ling.create(:name => 'level0') do |ling|
        ling.depth = 0
        ling.group = group
      end

      Ling.create(:name => "too-deep", :parent_id => parent.id) do |ling|
        ling.depth = 1
        ling.group = group
      end.should have(1).errors_on(:depth)
    end
  end

  describe "#grouped_name" do
    it "should use the appropriate depth type name from its parent group if it has a depth" do
      group = groups(:inclusive)
      Ling.create(:name => "foo") do |ling|
        ling.depth = 0
        ling.group = group
      end.grouped_name.should == group.ling0_name

      Ling.create(:name => "bar") do |ling|
        ling.depth = 1
        ling.group = group
      end.grouped_name.should == group.ling1_name
    end

    it "should use the depth 0 type name from its parent group if it is missing depth" do
      group = Factory(:group, :ling1_name => "", :depth_maximum => 0)
      Ling.create(:name => "baz") do |ling|
        ling.depth = nil
        ling.group = group
      end.grouped_name.should == group.ling0_name
    end
  end

  describe "#add_property" do
    before(:each) do
      @ling = lings(:level0)
      @property = mock_model(Property)
    end

    it "should create a new lings property if it does not exist" do
      lings_property = mock_model(LingsProperty)
      @ling.lings_properties.stub!(:exists?).and_return(false)
      @ling.lings_properties.should_receive(:create).with({
        :property_id => @property.id,
        :value => "new_value"
      }).and_return(lings_property)
      @ling.add_property("new_value", @property)
    end

    it "should return lings property if it exists" do
      @ling.lings_properties.should_receive(:exists?).with({
        :property_id => @property.id,
        :value => "existing_value"
      }).and_return(true)
      @ling.lings_properties.should_not_receive(:create)
      @ling.add_property("existing_value", @property)
    end
  end

  describe "StoredValues" do
    it_should_have_many :stored_values

    describe "#storable_keys" do
      it "should return the associated group's ling_storable_keys value if group is present" do
        group = groups(:inclusive)
        ling = Ling.create(:group => group)
        ling.storable_keys.should == group.ling_storable_keys
      end

      it "should return the an empty array if group is not present" do
        Ling.create.storable_keys.should == []
      end
    end

    describe "#stored_value" do
      it "should default available but unset keys to an empty string" do
        ling = lings(:level0)
        group = ling.group

        ling.storable_keys.should_not be_empty
        group.ling_storable_keys.should_not be_empty
        ling.stored_value(group.ling_storable_keys.first).should == ""
      end

      it "should return the value of in the associated StoredValue record if there is one" do
        ling = lings(:level0)
        ling.storable_keys.should_not be_empty

        key = ling.group.ling_storable_keys.first
        key.should be_present
        StoredValue.find_by_group_id_and_key_and_storable_type(ling.group.id, key, "Ling").should be_nil
        StoredValue.create(:storable => ling, :key => key, :value => "awesome")
        ling.reload.stored_value(key).should == "awesome"
      end

      it "should return nil if the key is invalid" do
        ling = lings(:level0)
        ling.storable_keys.should_not include "totallyfake"
        ling.stored_value("totallyfake").should be_nil
      end
    end

    describe "#store_value!" do
      it "should store the value for a valid key" do
        ling = lings(:level0)
        group = ling.group

        key = ling.storable_keys.first
        key.should be_present
        ling.store_value!(key, "foo")
        ling.reload.stored_value(key).should == "foo"
      end

      it "should have be able to update the value" do
        ling = lings(:level0)
        group = ling.group

        key = ling.storable_keys.last
        key.should be_present
        ling.store_value!(key, "foo")
        ling.reload.stored_value(key).should == "foo"

        ling.store_value!(key, "bar")
        ling.reload.stored_value(key).should == "bar"
      end

      it "should have be able to store a value for a key supplied by the group" do
        ling = lings(:level0)
        group = ling.group
        group.ling_fields = "custom_key"
        group.save
        group.reload

        key = group.ling_storable_keys.last
        key.should == "custom_key"
        Group::DEFAULT_LING_KEYS.should_not include key
        ling.storable_keys.should include key.to_s

        ling.store_value!(key, "baz")
        ling.stored_value(key).should == "baz"
      end

      it "should not save the value passed or report errors on the key name for unrecognized keys" do
        ling = lings(:level0)
        group = ling.group
        fake_key = "totallyfake"
        ling.storable_keys.should_not include fake_key
        ling.store_value!(fake_key, "bar")
        ling.reload.stored_value(fake_key).should be_nil
      end
    end
  end
end
