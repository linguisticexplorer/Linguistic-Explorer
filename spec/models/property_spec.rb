require 'spec_helper'

describe Property do
  describe "one-liners" do
    it_should_validate_presence_of :name, :category, :depth, :group
    it_should_validate_uniqueness_of :name
    it_should_validate_numericality_of :depth
    it_should_belong_to :group
#    should_validate_existence_of :group
  end

  describe "should be createable" do
    it "with depth 0" do
      should_be_createable :with => { :name => "depth 0", :category => "everything ever", :depth => 0, :group_id => Group.first.id }
    end

    it "with depth 1" do
      should_be_createable :with => { :name => "depth 1", :category => "everything ever", :depth => 1, :group_id => Group.first.id }
    end

    it "only if it has a depth" do
      Property.create(:name => "dat unique property", :category => "everything ever", :depth => nil, :group_id => Group.first.id ).should have_at_least(1).error_on(:depth)
    end
  end
end
