require 'rails_helper'

describe Category do
  describe "one-liners" do
    it { expect validate_presence_of :depth }
    it { expect validate_presence_of :group }
    it { expect validate_presence_of :name }
    it { expect validate_uniqueness_of(:name).scoped_to(:group_id) }
    it { expect validate_numericality_of :depth }
    it { expect have_many :properties }
    it { expect belong_to :group }
    it { expect belong_to :creator }

  end

  describe "createable with combinations" do
    describe "for multidepth groups" do
      it "should allow depth of 0" do
        expect do
          Category.create(:name => 'demos') do |cat|
            cat.group = FactoryGirl.create(:group, :depth_maximum => 1)
            cat.depth = 0
          end
        end.to change(Category, :count).by(1)
      end

      it "should allow depth of 1" do
        expect do
          Category.create(:name => 'linguistic') do |cat|
            cat.group = FactoryGirl.create(:group, :depth_maximum => 1)
            cat.depth = 1
          end
        end.to change(Category, :count).by(1)
      end
    end

    describe "for single depth groups" do
      it "should allow depth of 0" do
        expect do
          Category.create(:name => 'demos') do |cat|
            cat.group = FactoryGirl.create(:group, :depth_maximum => 0)
            cat.depth = 0
          end
        end.to change(Category, :count).by(1)
      end

      it "should not allow depth of 1" do
        expect do
          Category.create(:name => 'linguistic') do |cat|
            cat.group = FactoryGirl.create(:group, :depth_maximum => 0)
            cat.depth = 1
          end
        end.to change(Category, :count).by(0)
      end
    end
  end

  describe "ids_by_group_and_depth" do
    it "should return ids for given group and depth" do
      group = groups(:exclusive)
      depth = 0
      expect(Category.ids_by_group_and_depth(group, depth)).to eq [categories(:exclusive0).id]
    end

    it "should return empty array if there are no matching categories" do
      group = groups(:exclusive)
      depth = 1
      Category.delete_all

      expect(Category.ids_by_group_and_depth(group, depth)).to be_empty
    end
  end
end
