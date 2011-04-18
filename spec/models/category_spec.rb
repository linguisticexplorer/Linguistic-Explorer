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
    describe "for multidepth groups" do
      it "should allow depth of 0" do
        lambda do
          Category.create(:name => 'demos') do |cat|
            cat.group = Factory(:group, :depth_maximum => 1)
            cat.depth = 0
          end
        end.should change(Category, :count).by(1)
      end

      it "should allow depth of 1" do
        lambda do
          Category.create(:name => 'linguistic') do |cat|
            cat.group = Factory(:group, :depth_maximum => 1)
            cat.depth = 1
          end
        end.should change(Category, :count).by(1)
      end
    end

    describe "for single depth groups" do
      it "should allow depth of 0" do
        lambda do
          Category.create(:name => 'demos') do |cat|
            cat.group = Factory(:group, :depth_maximum => 0)
            cat.depth = 0
          end
        end.should change(Category, :count).by(1)
      end

      it "should not allow depth of 1" do
        lambda do
          Category.create(:name => 'linguistic') do |cat|
            cat.group = Factory(:group, :depth_maximum => 0)
            cat.depth = 1
          end
        end.should change(Category, :count).by(0)
      end
    end
  end

  describe "ids_by_group_and_depth" do
    it "should return ids for given group and depth" do
      group = groups(:exclusive)
      depth = 0
      Category.ids_by_group_and_depth(group, depth).should == [categories(:exclusive0).id]
    end
    it "should return empty array if no ids" do
      group = groups(:exclusive)
      depth = 1
      Category.ids_by_group_and_depth(group, depth).should be_empty
    end
  end
end
