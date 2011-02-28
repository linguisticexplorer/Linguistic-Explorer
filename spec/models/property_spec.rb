require 'spec_helper'

describe Property do
  describe "one-liners" do
    it_should_validate_presence_of :name, :category, :group
    it_should_validate_uniqueness_of :name, :scope => :group_id
    it_should_belong_to :group
    it_should_belong_to :category

    it_should_have_many :lings_properties
#    should_validate_existence_of :group, :category
  end

  describe "should be createable" do
    it "with a category" do
      should_be_createable :with => { :name => "depth 0", :category_id => groups(:inclusive).categories.first.id, :group_id => groups(:inclusive).id }
    end
  end
end
