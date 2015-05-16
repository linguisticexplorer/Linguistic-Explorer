require 'rails_helper'

describe Example do
  describe "one-liners" do
    it { expect validate_presence_of :group }
    it { expect belong_to :ling }
    it { expect belong_to :group }
    it { expect belong_to :creator }
    it { expect have_many :examples_lings_properties }
    it { expect have_many :lings_properties }
  end

  describe "should be createable" do
    it "with a ling and that ling's group id" do
      ling = lings(:level0)
      expect do
        Example.create(:ling_id => ling.id, :name => 'example-with-ling_id') do |e|
          e.group = ling.group
        end
      end.to change(Example, :count).by(1)
    end

    it "unless the ling and group_id don't match" do
      ling = groups(:inclusive).lings.first
      group = groups(:exclusive)
      expect(Example.create(:ling_id => ling.id, :name => 'example-with-mismatched-object-refs') do |e|
        e.group = group
      end).to have(1).error_on(:ling)
    end

    it "without a ling" do
      expect do
        Example.create(:name => 'example-without-ling_id') do |e|
          e.group = groups(:inclusive)
        end
      end.to change(Example, :count).by(1)
    end
  end

  describe "#grouped_name" do
    it "should return the Example name from its associated group" do
      example = examples(:inclusive)
      expect(example.group.example_name).to eq example.grouped_name
    end
  end

  describe "StoredValues" do
    it { expect have_many :stored_values }

    describe "#storable_keys" do
      it "should return the associated group's example_storable_keys value if group is present" do
        group = groups(:inclusive)
        expect(Example.create(:group => group).storable_keys).to eq group.example_storable_keys
      end

      it "should return the an empty array if group is not present" do
        expect(Example.create.storable_keys).to eq []
      end
    end

    describe "#stored_value" do
      it "should default available but unset keys to an empty string" do
        example = examples(:valueless)
        expect(example.storable_keys).to include "description"
        expect(example.stored_value(:description)).to eq ""
      end

      it "should return the value of in the associated StoredValue record if there is one" do
        example = examples(:inclusive)
        expect(example.storable_keys).to include "description"
        expect(StoredValue.find_by_group_id_and_key(example.group.id, "description")).to be_nil
        StoredValue.create(:storable => example, :key => "description", :value => "awesome")
        expect(example.reload.stored_value(:description)).to eq "awesome"
      end

      it "should return nil if the key is invalid" do
        example = examples(:inclusive)
        expect(example.storable_keys).not_to include "totallyfake"
        expect(example.stored_value("totallyfake")).to be_nil
      end
    end

    describe "#store_value!" do
      it "should store the value for a valid key" do
        ling = lings(:level0)
        group = ling.group
        example = Example.create(:ling_id => ling.id, :name => 'has-text') do |e|
          e.group = group
        end
        expect(example.storable_keys).to include "description"
        example.store_value!(:description, "foo")
        expect(example.reload.stored_value(:description)).to eq "foo"
      end

      it "should have be able to update the value" do
        ling = lings(:level0)
        group = ling.group
        example = Example.create(:ling_id => ling.id, :name => 'has-text') do |e|
          e.group = group
        end
        expect(example.storable_keys).to include "description"
        example.store_value!(:description, "foo")
        expect(example.reload.stored_value(:description)).to eq "foo"

        example.store_value!(:description, "bar")
        expect(example.reload.stored_value(:description)).to eq "bar"
      end

      it "should have be able to store a value for a key supplied by the group" do
        ling = lings(:level0)
        group = ling.group
        group.example_fields = "custom_key"
        group.save
        group.reload

        key = group.example_storable_keys.last
        expect(key).to eq "custom_key"
        expect(Group::DEFAULT_EXAMPLE_KEYS).not_to include key

        example = Example.create(:ling_id => ling.id, :name => 'has-text') do |e|
          e.group = group
        end

        expect(example.storable_keys).to include key.to_s
        example.store_value!(key, "baz")
        expect(example.stored_value(key)).to eq "baz"
      end

      it "should not save the value passed or report errors on the key name for unrecognized keys" do
        ling = lings(:level0)
        group = ling.group
        example = Example.create(:ling_id => ling.id, :name => 'has-text') do |e|
          e.group = group
        end
        expect(example.storable_keys).not_to include "totallyfake"
        example.store_value!(:totallyfake, "bar")
        expect(example.reload.stored_value(:totallyfake)).to be_nil
      end
    end
  end
end
