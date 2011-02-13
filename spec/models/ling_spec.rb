require 'spec_helper'

describe Ling do
  describe "one-liners" do
    it_should_validate_presence_of :name, :depth
    it_should_validate_uniqueness_of :name
    it_should_validate_numericality_of :depth

    it_should_have_many :examples, :children, :lings_properties, :children
    it_should_belong_to :parent

#    should_validate_existence_of :parent, :allow_nil => true
  end

  describe "createable with combinations" do
    it "should allow depth of 0 or 1 with nil parent_id" do
      should_be_createable :with => {:parent_id => nil, :depth => 0, :name => 'toes'}
      should_be_createable :with => {:parent_id => nil, :depth => 1, :name => 'bees knees'}
    end

    it "should allow depth 1 lings to have depth 0 parents" do
      should_be_createable :with => {:parent_id => lings(:level0).id, :name => 'snarfblat', :depth => 1}
    end

    it "should not allow depth 1 lings to have depth 1 parents" do
      Ling.create(:name => "unik d1", :depth => 1, :parent_id => lings(:level1orphan).id).should have(1).errors_on(:parent)
    end
  end
end
