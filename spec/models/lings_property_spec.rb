require 'spec_helper'

describe LingsProperty do
  describe "one-liners" do
    it_should_validate_presence_of :ling_id, :property_id, :value, :group_id
    it_should_belong_to :ling, :property, :group
#    should_validate_existence_of :ling, :property, :group
  end

  describe "should be createable" do
    it "with a ling and property of the same depth and group" do
      group = groups(:inclusive)
      ling0 = group.lings.select{|l| l.depth == 0}.first
      ling1 = group.lings.select{|l| l.depth == 1}.first
      prop0 = group.properties.select{|p| p.depth == 0}.first
      prop1 = group.properties.select{|p| p.depth == 1}.first
      should_be_createable :with => {:ling_id => ling0.id, :property_id => prop0.id, :value => 'foo', :group_id => group.id }
      should_be_createable :with => {:ling_id => ling1.id, :property_id => prop1.id, :value => 'foo', :group_id => group.id }
    end

    it "only with lings and property of the same depth" do
      group = groups(:inclusive)
      ling0 = group.lings.select{|l| l.depth == 0}.first
      ling1 = group.lings.select{|l| l.depth == 1}.first
      prop0 = group.properties.select{|p| p.depth == 0}.first
      prop1 = group.properties.select{|p| p.depth == 1}.first
      LingsProperty.create(:ling_id => ling0.id, :property_id => prop1.id, :value => 'baz', :group_id => group.id ).should have(1).error_on :depth
      LingsProperty.create(:ling_id => ling1.id, :property_id => prop0.id, :value => 'bar', :group_id => group.id ).should have(1).error_on :depth
    end

    it "only with lings and property of the same group as the group_id" do
      ling = groups(:inclusive).lings.select{|l| l.depth == 0}.first
      prop = groups(:exclusive).properties.select{|p| p.depth == 0}.first
      propINC = groups(:inclusive).properties.select{|p| p.depth == 0}.first
      LingsProperty.create(:ling_id => ling.id, :property_id => prop.id, :value => 'group mismatch', :group_id => groups(:inclusive).id).should have(1).error_on :group
      LingsProperty.create(:ling_id => ling.id, :property_id => prop.id, :value => 'group mismatch', :group_id => groups(:exclusive).id).should have(1).error_on :group
      LingsProperty.create(:ling_id => ling.id, :property_id => propINC.id, :value => 'group mismatch', :group_id => groups(:exclusive).id).should have(1).error_on :group
    end
  end
end
