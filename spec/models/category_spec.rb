require 'spec_helper'

describe Category do
  describe "one-liners" do
    it_should_validate_presence_of :depth, :group, :name
    it_should_validate_uniqueness_of :name, :scope => :group_id
    it_should_validate_numericality_of :depth
    it_should_have_many :properties
    it_should_belong_to :group, :creator

#    should_validate_existence_of :group, :creator
  end

  describe "createable with combinations" do
    it "should allow depth of 0" do
      should_be_createable :with => { :depth => 0, :name => 'demos', :group_id => Group.first.id }
    end

    it "should allow depth of 1" do
      should_be_createable :with => { :depth => 0, :name => 'linguistic', :group_id => Group.first.id }
    end
  end
end
