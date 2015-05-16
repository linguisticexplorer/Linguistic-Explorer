require 'spec_helper'

describe Ling do
  describe "one-liners" do
    it { expect validate_presence_of :name }
    it { expect validate_presence_of :depth }
    it { expect validate_presence_of :group }
    it { expect validate_uniqueness_of(:name).scoped_to(:group_id) }
    it { expect validate_numericality_of :depth }
    it { expect have_many :examples }
    it { expect have_many :children }
    it { expect have_many :lings_properties }
    it { expect have_many :children }
    it { expect belong_to :parent }
    it { expect belong_to :group }
    it { expect belong_to :creator }
  end

  describe "createable with combinations" do
    it "should allow depth of 0 or 1 with nil parent_id" do
      expect do
        Ling.create(:parent_id => nil, :name => 'toes') do |ling|
          ling.group = groups(:inclusive)
          ling.depth = 0
        end
      end.to change(Ling, :count).by(1)

      expect do
        Ling.create(:parent_id => nil, :name => 'twinkle') do |ling|
          ling.group = groups(:inclusive)
          ling.depth = 1
        end
      end.to change(Ling, :count).by(1)
    end

    it "should allow depth 1 lings to have depth 0 parents" do
      parent = lings(:level0)
      expect do
        Ling.create(:parent_id => parent.id, :name => 'snarfblat') do |ling|
          ling.group = parent.group
          ling.depth = 1
        end
      end.to change(Ling, :count).by(1)
    end

    it "should not allow ling to belong to a different group" do
      ling = groups(:inclusive).lings.select{|l| l.depth eq 0}.first
      group = groups(:exclusive)
      expect do
        Ling.create(:name => "misgrouped", :parent_id => ling.id) do |l|
          l.group = group
          l.depth = 1
        end
      end.to have(1).errors_on(:parent)
    end

    it "should not allow ling creation of a depth greater than the group maximum" do
      group = FactoryGirl.create(:group, :depth_maximum => 0)
      expect(group.depth_maximum).to eq 0
      parent = Ling.create(:name => 'level0') do |ling|
        ling.depth = 0
        ling.group = group
      end
      expect do
        Ling.create(:name => "too-deep", :parent_id => parent.id) do |ling|
          ling.depth = 1
          ling.group = group
        end
      end.to have(1).errors_on(:depth)
    end
  end

  describe "#grouped_name" do
    it "should use the appropriate depth type name from its parent group if it has a depth" do
      group = groups(:inclusive)
      expect do
        Ling.create(:name => "foo") do |ling|
          ling.depth = 0
          ling.group = group
        end.grouped_name
      end.to eq group.ling0_name
      
      expect do
        Ling.create(:name => "bar") do |ling|
          ling.depth = 1
          ling.group = group
        end.grouped_name
      end.to eq group.ling1_name
    end

    it "should use the depth 0 type name from its parent group if it is missing depth" do
      group = FactoryGirl.create(:group, :ling1_name => "", :depth_maximum => 0)
      expect do
        Ling.create(:name => "baz") do |ling|
          ling.depth = nil
          ling.group = group
        end.grouped_name
      end.to eq group.ling0_name
    end
  end

  describe "#add_property" do
    before(:each) do
      @ling = lings(:level0)
      @property = mock_model(Property)
    end

    it "should create a new lings property if it does not exist" do
      lings_property = mock_model(LingsProperty)
      allow(@ling.lings_properties).to receive_message_chain(:exists?).and_return(false)
      expect(@ling.lings_properties).to receive(:create).with({
        :property_id => @property.id,
        :value => "new_value"
      }).and_return(lings_property)
      @ling.add_property("new_value", @property)
    end

    it "should return lings property if it exists" do
      expect(@ling.lings_properties).to receive(:exists?).with({
        :property_id => @property.id,
        :value => "existing_value"
      }).and_return(true)
      expect(@ling.lings_properties).not_to receive(:create)
      @ling.add_property("existing_value", @property)
    end
  end

  describe "StoredValues" do
    it { expect have_many :stored_values }

    describe "#storable_keys" do
      it "should return the associated group's ling_storable_keys value if group is present" do
        group = groups(:inclusive)
        ling = Ling.create(:group => group)
        expect(ling.storable_keys).to eq group.ling_storable_keys
      end

      it "should return the an empty array if group is not present" do
        expect(Ling.create.storable_keys).to eq []
      end
    end

    describe "#stored_value" do
      it "should default available but unset keys to an empty string" do
        ling = lings(:level0)
        group = ling.group

        expect(ling.storable_keys).not_to be_empty
        expect(group.ling_storable_keys).not_to be_empty
        expect(ling.stored_value(group.ling_storable_keys.first)).to eq ""
      end

      it "should return the value of in the associated StoredValue record if there is one" do
        ling = lings(:level0)
        ling.storable_keys.not_to be_empty

        key = ling.group.ling_storable_keys.first
        expect(key).to be_present
        expect(StoredValue.find_by_group_id_and_key_and_storable_type(ling.group.id, key, "Ling")).to be_nil
        StoredValue.create(:storable => ling, :key => key, :value => "awesome")
        expect(ling.reload.stored_value(key)).to eq "awesome"
      end

      it "should return nil if the key is invalid" do
        ling = lings(:level0)
        expect(ling.storable_keys).not_to include "totallyfake"
        expect(ling.stored_value("totallyfake")).to be_nil
      end
    end

    describe "#store_value!" do
      it "should store the value for a valid key" do
        ling = lings(:level0)
        group = ling.group

        key = ling.storable_keys.first
        expect(key).to be_present
        ling.store_value!(key, "foo")
        expect(ling.reload.stored_value(key)).to eq "foo"
      end

      it "should have be able to update the value" do
        ling = lings(:level0)
        group = ling.group

        key = ling.storable_keys.last
        expect(key).to be_present
        ling.store_value!(key, "foo")
        expect(ling.reload.stored_value(key)).to eq "foo"

        ling.store_value!(key, "bar")
        expect(ling.reload.stored_value(key)).to eq "bar"
      end

      it "should have be able to store a value for a key supplied by the group" do
        ling = lings(:level0)
        group = ling.group
        group.ling_fields = "custom_key"
        group.save
        group.reload

        key = group.ling_storable_keys.last
        expect(key).to eq "custom_key"
        expect(Group::DEFAULT_LING_KEYS).not_to include key
        expect(ling.storable_keys).to include key.to_s

        ling.store_value!(key, "baz")
        expect(ling.stored_value(key)).to eq "baz"
      end

      it "should not save the value passed or report errors on the key name for unrecognized keys" do
        ling = lings(:level0)
        group = ling.group
        fake_key = "totallyfake"
        expect(ling.storable_keys).not_to include fake_key
        ling.store_value!(fake_key, "bar")
        expect(ling.reload.stored_value(fake_key)).to be_nil
      end
    end
  end
end
