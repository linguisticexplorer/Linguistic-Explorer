require 'spec_helper'

describe Group do
  describe "one-liners" do
    it_should_validate_presence_of :name
    it_should_validate_uniqueness_of :name
    it_should_have_many :lings, :properties, :lings_properties, :examples, :categories
    it_should_have_many :group_memberships, :users
  end

  describe "should be createable" do
    it "with a name" do
      should_be_createable :with => { :name => 'myfirstgroup' }
    end
  end

  describe ".ling_name_for_depth" do
    it "should return the level 0 ling name when passed a 0" do
      Group.new(:name => "foo", :depth_maximum => 0, :ling0_name => "foo_0").ling_name_for_depth(0).should == "foo_0"
    end

    it "should return the level 1 ling name when passed a 1" do
      Group.new(:name => "bar", :depth_maximum => 1, :ling1_name => "bar_1").ling_name_for_depth(1).should == "bar_1"
    end

    it "should return an error message with the requested/unavailable depth mentioned if the depth is too large" do
      message = Group.new(:name => "baz", :depth_maximum => 0, :ling1_name => "huehue").ling_name_for_depth(1)
      message.should =~ /Error/
      message.should =~ /1/
    end
  end
end
