require 'spec_helper'

describe ExamplesLingsProperty do
  describe "one-liners" do
    it_should_validate_presence_of :example, :lings_property, :group
    it_should_validate_uniqueness_of :example_id, :scope => :lings_property_id
    it_should_belong_to :example, :lings_property, :group, :creator
#    should_validate_existence_of :example, :lings_property, :group, :creator
  end

  describe "should be createable" do
    it "with an example and lings_property of the same group" do
      should_be_createable :with => {
            :lings_property_id => lings_properties(:inclusive).id,
            :example_id => examples(:inclusive).id,
            :group_id => groups(:inclusive).id
      }
    end

    it "only with examples and lings_properties of the same group as the group_id" do
      example = examples(:inclusive)
      lings_propIN = lings_properties(:inclusive)
      lings_propEX = lings_properties(:exclusive)
      ExamplesLingsProperty.create(:example_id => example.id, :lings_property_id => lings_propEX.id, :group_id => groups(:inclusive).id).should have(1).errors
      ExamplesLingsProperty.create(:example_id => example.id, :lings_property_id => lings_propEX.id, :group_id => groups(:exclusive).id).should have(1).errors
      ExamplesLingsProperty.create(:example_id => example.id, :lings_property_id => lings_propIN.id, :group_id => groups(:exclusive).id).should have(1).errors
    end

    it "only with an example whose ling is the same as the lings_property's ling" do
      group = groups(:inclusive)
      lp_for_one_ling = lings_properties(:inclusive)
      example_for_another_ling = Example.create(:group => group, :ling => Factory(:ling, :name => 'another', :group => group))
      ExamplesLingsProperty.create(:example_id => example_for_another_ling.id, :lings_property_id => lp_for_one_ling.id, :group_id => groups(:inclusive).id).should have(1).errors
    end
  end
end
