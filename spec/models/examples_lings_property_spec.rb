require 'spec_helper'

describe ExamplesLingsProperty do
  describe "one-liners" do
    it { expect validate_presence_of :example }
    it { expect validate_presence_of :lings_property }
    it { expect validate_presence_of :group }
    it { expect validate_uniqueness_of(:example_id).scoped_to(:lings_property_id) }
    it { expect belong_to :example }
    it { expect belong_to :lings_property }
    it { expect belong_to :group }
    it { expect belong_to :creator }
  end

  describe "should be createable" do
    it "with an example and lings_property of the same group" do
      expect do
        ExamplesLingsProperty.create(:lings_property_id => lings_properties(:inclusive).id, :example_id => examples(:inclusive).id) do |elp|
          elp.group = groups(:inclusive)
        end
      end.to change(ExamplesLingsProperty, :count).by(1)
    end

    it "only with examples and lings_properties of the same group as the group_id" do
      group = groups(:inclusive)
      misgroup = groups(:exclusive)
      example = examples(:inclusive)
      lings_propIN = lings_properties(:inclusive)
      lings_propEX = lings_properties(:exclusive)

      expect do
        ExamplesLingsProperty.create(:example_id => example.id, :lings_property_id => lings_propEX.id) do |elp|
          elp.group = group
        end
      end.to have(2).errors

      expect do
        ExamplesLingsProperty.create(:example_id => example.id, :lings_property_id => lings_propEX.id) do |elp|
          elp.group = misgroup
        end
      end.to have(2).errors

      expect do
        ExamplesLingsProperty.create(:example_id => example.id, :lings_property_id => lings_propIN.id) do |elp|
          elp.group = misgroup
        end
      end.to have(1).errors
    end

    it "only with an example whose ling is the same as the lings_property's ling" do
      group = groups(:inclusive)
      lp_for_one_ling = lings_properties(:inclusive)
      example_for_another_ling = Example.create(:group => group, :ling => FactoryGirl.create(:ling, :name => 'another', :group => group))
      expect do
        ExamplesLingsProperty.create(:example_id => example_for_another_ling.id, :lings_property_id => lp_for_one_ling.id) do |elp|
          elp.group = groups(:inclusive)
        end
      end.to have(1).errors
    end
  end
end
