require 'spec_helper'

describe Category do
  describe "one-liners" do
    it { should validate_presence_of :depth }
    it { should validate_presence_of :group }
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of(:name).scoped_to(:group_id) }
    it { should validate_numericality_of :depth }
    it { should have_many :properties }
    it { should belong_to :group }
    it { should belong_to :creator }
    # it_should_validate_presence_of :depth, :group, :name
    # it_should_validate_uniqueness_of :name, :scope => :group_id
    # it_should_validate_numericality_of :depth
    # it_should_have_many :properties
    # it_should_belong_to :group, :creator

  end

  describe "createable with combinations" do
    describe "for multidepth groups" do
      it "should allow depth of 0" do
        lambda do
          Category.create(:name => 'demos') do |cat|
            cat.group = FactoryGirl.create(:group, :depth_maximum => 1)
            cat.depth = 0
          end
        end.should change(Category, :count).by(1)
      end

      it "should allow depth of 1" do
        lambda do
          Category.create(:name => 'linguistic') do |cat|
            cat.group = FactoryGirl.create(:group, :depth_maximum => 1)
            cat.depth = 1
          end
        end.should change(Category, :count).by(1)
      end
    end

    describe "for single depth groups" do
      it "should allow depth of 0" do
        lambda do
          Category.create(:name => 'demos') do |cat|
            cat.group = FactoryGirl.create(:group, :depth_maximum => 0)
            cat.depth = 0
          end
        end.should change(Category, :count).by(1)
      end

      it "should not allow depth of 1" do
        lambda do
          Category.create(:name => 'linguistic') do |cat|
            cat.group = FactoryGirl.create(:group, :depth_maximum => 0)
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

    it "should return empty array if there are no matching categories" do
      group = groups(:exclusive)
      depth = 1
      Category.delete_all

      Category.ids_by_group_and_depth(group, depth).should be_empty
    end
  end
end
