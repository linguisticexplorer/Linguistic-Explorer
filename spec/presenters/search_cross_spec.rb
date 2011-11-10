require 'spec_helper'

describe SearchCross do

  describe "Same ids-parents" do
    before do
      @presenter = SearchCross.new([1,2,3])
    end

    it "should return true is parents are same of ids" do
      @presenter.are_parent_ids?(create_objects(3)).should be_true
    end
  end

  describe "Size check" do
    before do
      @presenter = SearchCross.new([1,2,3])
    end

    it "should return false if parents are more than ids" do
      @presenter.are_parent_ids?(create_objects(4)).should be_false
    end

    it "should return false if parents are less than ids" do
      @presenter.are_parent_ids?(create_objects(2)).should be_false
    end
  end

  describe "Not Same Ids-Parents" do
    before do
      @presenter = SearchCross.new([1,4,5])
    end

    it "should return false is parents are different from ids" do
      @presenter.are_parent_ids?(create_objects(3)).should be_false
    end

  end

  def create_objects(max)
    [].tap do |lp|
      (1..max).each do |id|
        lp << Factory(:group, :name => "object_#{id}", :id=>id)
      end
    end
  end
end