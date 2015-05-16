require 'spec_helper'

describe Group do
  describe "one-liners" do
    it { expect validate_presence_of :name }
    it { expect validate_uniqueness_of :name }
    it { expect validate_numericality_of(:depth_maximum) }
    it { expect have_many :lings }
    it { expect have_many :lings_properties }
    it { expect have_many :examples_lings_properties }
    it { expect have_many :examples }
    it { expect have_many :categories }
    it { expect have_many :memberships }
    it { expect have_many :members }
    it { expect have_many :searches }
  end

  describe "should be createable" do
    it "with a name and depth max and privacy" do
      # Also here, waiting for a better macro...
      expect { Group.create :name => 'myfirstgroup', :depth_maximum => 0, :privacy => Group::PUBLIC }.not_to raise_error
    end
  end

  describe "#ling_name_for_depth" do
    it "should return the level 0 ling name when passed a 0" do
      expect(Group.new(:name => "foo",
                :depth_maximum => 0,
                :privacy => Group::PRIVATE,
                :ling0_name => "foo_0").ling_name_for_depth(0)).to eq "foo_0"
    end

    it "should return the level 1 ling name when passed a 1" do
      expect(Group.new(:name => "bar",
                :depth_maximum => 1,
                :privacy => Group::PUBLIC,
                :ling1_name => "bar_1").ling_name_for_depth(1)).to eq "bar_1"
    end

    it "should raise an exception with an out of bounds depth argument" do
      expect do
        Group.new(:name => "baz", :depth_maximum => 0, :privacy => Group::PRIVATE, :ling1_name => "huehue").ling_name_for_depth(1)
      end.to raise_exception
    end
  end

  describe "#ling_names" do
    it "should return an array with ling0 name only if in a single depth group" do
      expect(Group.new(:name => "foo", :privacy => Group::PRIVATE, :depth_maximum => 0, :ling0_name => "foo").ling_names).to eq ["foo"]
    end

    it "should return an array with ling0 and ling1 name if in a multi depth group" do
      expect(Group.new(:name => "foo", :privacy => Group::PRIVATE, :depth_maximum => 1, :ling0_name => "foo", :ling1_name => "bar").ling_names).to eq ["foo", "bar"]
    end
  end

  describe "#depths" do
    it "should return an array [0] to a no depth group" do
      expect(FactoryGirl.create(:group, :depth_maximum => 0).depths).to eq [ 0 ]
    end

    it "should return an array of the available depths to the group" do
      expect(FactoryGirl.create(:group, :depth_maximum => 1).depths).to eq [0, 1]
    end
  end

  describe "#example_storable_keys" do
    it "should by default have the key 'description'" do
      expect(Group.new.example_storable_keys).to include 'description'
    end

    describe "should return an array of strings created from example_fields" do
      it "that has only default keys if the field is empty" do
        expect(FactoryGirl.create(:group, :example_fields => "").example_storable_keys).to eq ['description']
      end

      it "should ignore duplicates" do
        expect(FactoryGirl.create(:group, :example_fields => "description, foo, foo").example_storable_keys).to eq ["description", "foo"]
      end

      it "that splits on commas if fields has any" do
        expect(FactoryGirl.create(:group, :example_fields => "foo,bar").example_storable_keys).to eq [ "description", "foo", "bar"]
      end

      it "that strips leading and trailing whitespace from all values" do
        expect(FactoryGirl.create(:group, :example_fields => " foo , bar ").example_storable_keys).to eq [ "description", "foo", "bar"]
      end
    end
  end

  describe "#ling_storable_keys" do
    it "should by default have description" do
      expect(Group.new.ling_storable_keys).to include 'description'
    end

    describe "should return an array of strings created from example_fields" do
      it "that has only default keys if the field is empty" do
        expect(FactoryGirl.create(:group, :ling_fields => "").ling_storable_keys).to eq ['description']
      end

      it "should ignore duplicates" do
        expect(FactoryGirl.create(:group, :ling_fields => "description, foo, foo").ling_storable_keys).to eq ["description", "foo"]
      end

      it "that splits on commas if fields has any" do
        expect(FactoryGirl.create(:group, :ling_fields => "foo,bar").ling_storable_keys).to eq ["description", "foo", "bar"]
      end

      it "that strips leading and trailing whitespace from all values" do
        expect(FactoryGirl.create(:group, :ling_fields => " foo , bar ").ling_storable_keys).to eq ["description", "foo", "bar"]
      end
    end
  end
end
