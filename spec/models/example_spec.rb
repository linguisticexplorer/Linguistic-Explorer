require 'spec_helper'

describe Example do
  describe "one-liners" do
    it_should_validate_presence_of :group
    it_should_belong_to :ling, :group, :creator
#    should_validate_existence_of :group
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

  #it should probably validate attributes when those come in
end
