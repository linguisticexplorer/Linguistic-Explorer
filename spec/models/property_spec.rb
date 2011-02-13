require 'spec_helper'

describe Property do
  describe "one-liners" do
    it_should_validate_presence_of :name, :category, :depth
    it_should_validate_uniqueness_of :name
    it_should_validate_numericality_of :depth
  end

  describe "should be createable" do
    it "with depth 0" do
      should_be_createable :with => { :name => "depth 0", :category => "everything ever", :depth => 0}
    end

    it "with depth 1" do
      should_be_createable :with => { :name => "depth 1", :category => "everything ever", :depth => 1 }
    end

    it "only if it has a depth" do
      Property.create(:name => "dat unique property", :category => "everything ever", :depth => nil).should have_at_least(1).error_on(:depth)
    end
  end
end
