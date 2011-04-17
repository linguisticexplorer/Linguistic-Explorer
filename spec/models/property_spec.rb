require 'spec_helper'

describe Property do
  describe "one-liners" do
    it_should_validate_presence_of :name, :category, :group
    it_should_validate_uniqueness_of :name, :scope => :group_id

    it_should_belong_to :group, :creator, :category
    it_should_have_many :lings_properties
#    should_validate_existence_of :group, :category, :creator
  end

  describe "should be createable" do
    it "with a category" do
      should_be_createable :with => { :name => "depth 0", :category_id => groups(:inclusive).categories.first.id, :group_id => groups(:inclusive).id }
    end

    it "unless category does not belong to the same group" do
      Property.create( :name => "misgrouped", :category_id => groups(:inclusive).categories.first.id, :group_id => groups(:exclusive).id ).should have(1).errors_on(:category)
    end
  end

  describe "#available_values" do
    it "should return an arrow of values from lings_properties related to itself" do
      prop = properties(:level0)
      lp = lings_properties(:level0)
      prop.lings_properties.should include lp
      prop.available_values.should include lp.value
    end
  end
end
