require 'spec_helper'

describe LingsProperty do
  describe "one-liners" do
    it_should_validate_presence_of :ling, :property, :value, :group
    it_should_validate_uniqueness_of :value, :scope => [:ling_id, :property_id]
    it_should_belong_to :ling, :property, :group
#    should_validate_existence_of :ling, :property, :group
  end

  describe "should be createable" do
    it "with a ling and property of the same depth and group" do
      group = groups(:inclusive)
      should_be_createable :with => {:ling_id => lings(:level0).id, :property_id => properties(:level0).id, :value => 'foo', :group_id => group.id }
      should_be_createable :with => {:ling_id => lings(:level1).id, :property_id => properties(:level1).id, :value => 'foo', :group_id => group.id }
    end

    it "only with lings and property of the same depth" do
      group = groups(:inclusive)
      LingsProperty.create(:ling_id => lings(:level0).id, :property_id => properties(:level1).id, :value => 'baz', :group_id => group.id ).should have(1).error_on :depth
      LingsProperty.create(:ling_id => lings(:level1).id, :property_id => properties(:level0).id, :value => 'bar', :group_id => group.id ).should have(1).error_on :depth
    end

    it "only with lings and property of the same group as the group_id" do
      ling = lings(:level0)
      propEX = properties(:exclusive0)
      propINC = properties(:level0)
      LingsProperty.create(:ling_id => ling.id, :property_id => propEX.id, :value => 'group mismatch', :group_id => groups(:inclusive).id).should have(1).error_on :group
      LingsProperty.create(:ling_id => ling.id, :property_id => propEX.id, :value => 'group mismatch', :group_id => groups(:exclusive).id).should have(1).error_on :group
      LingsProperty.create(:ling_id => ling.id, :property_id => propINC.id, :value => 'group mismatch', :group_id => groups(:exclusive).id).should have(1).error_on :group
    end
  end
end
