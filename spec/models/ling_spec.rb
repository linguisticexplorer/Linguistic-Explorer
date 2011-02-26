require 'spec_helper'

describe Ling do
  describe "one-liners" do
    it_should_validate_presence_of :name, :depth, :group
    it_should_validate_uniqueness_of :name, :scope => :group_id
    it_should_validate_numericality_of :depth

    it_should_have_many :examples, :children, :lings_properties, :children
    it_should_belong_to :parent, :group

#    should_validate_existence_of :group
#    should_validate_existence_of :parent, :allow_nil => true
  end

  describe "createable with combinations" do
    it "should allow depth of 0 or 1 with nil parent_id" do
      should_be_createable :with => { :parent_id => nil, :depth => 0, :name => 'toes', :group_id => Group.first.id }
      should_be_createable :with => { :parent_id => nil, :depth => 1, :name => 'bees knees', :group_id => Group.first.id }
    end

    it "should allow depth 1 lings to have depth 0 parents" do
      ling = lings(:level0)
      should_be_createable :with => { :parent_id => ling.id, :name => 'snarfblat', :depth => 1, :group_id => ling.group.id }
    end

    it "should not allow ling to belong to a different group" do
      ling = groups(:inclusive).lings.select{|l| l.depth == 0}.first
      group = groups(:exclusive)
      Ling.create(:name => "misgrouped", :depth => 1, :parent_id => ling.id, :group_id => group.id).should have(1).errors_on(:group)
    end
  end
  
  describe "add_property" do
    before(:each) do
      @ling = Ling.first
      @property = mock_model(Property)
    end

    it "should create a new lings property if it does not exist" do
      lings_property = mock_model(LingsProperty)
      @ling.lings_properties.stub!(:exists?).and_return(false)
      @ling.lings_properties.should_receive(:create).with({
        :property_id => @property.id,
        :group_id => @ling.group.id,
        :value => "new_value"
      }).and_return(lings_property)
      @ling.add_property("new_value", @property)
    end
    it "should return lings property if it exists" do
      @ling.lings_properties.should_receive(:exists?).with({
        :property_id => @property.id,
        :group_id => @ling.group.id,
        :value => "existing_value"
      }).and_return(true)
      @ling.lings_properties.should_not_receive(:create)
      @ling.add_property("existing_value", @property)
    end
  end
end
