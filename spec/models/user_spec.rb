require 'spec_helper'

describe User do
  before(:each) do
    @user = User.new
  end

  describe "one-liners" do
    it_should_validate_presence_of :name, :email, :access_level
    it_should_have_many :memberships, :groups, :searches
  end

  describe "createable with combinations" do
    it "should allow sane looking names and passwords, and require access_level and email after the fact" do
      u = User.new(:name => "FIXME", :password => "password")
      u.email = "FIXME@FiX.com"
      u.access_level = "user"
      u.bypass_humanizer = true
      u.save!
      u.should_not be_new_record
    end
  end

  describe "#admin?" do
    it "should be truthy only if the user has access_level of admin" do
      Factory(:user, :email => "one@example.com", :access_level => "admin").admin?.should be_true
      Factory(:user, :email => "two@example.com", :access_level => "not").admin?.should_not be_true
    end
  end

  describe "#administrated_groups" do
    it "should return the set of groups for which a user is an admin" do
      user = Factory(:user, :email => "one@example.com", :access_level => "user")
      group = Factory(:group)

      Membership.create(:level => "admin", :group => group, :member => user)
      user.administrated_groups.should include(group)
    end
  end

  describe "reached_max_search_limit?" do
    it "should return reached max limit for search by group" do
      group = mock(Group)
      Search.should_receive(:reached_max_limit?).with(@user, group).and_return(true)
      @user.reached_max_search_limit?(group).should be_true
    end
    it "should return reached max limit for search by group" do
      Search.stub!(:reached_max_limit?).and_return(false)
      @user.reached_max_search_limit?(mock(Group)).should be_false
    end
  end

  describe "member_of?" do
    before(:each) do
      @group_1 = Factory(:group, :name => "Group 1")
      @group_2 = Factory(:group, :name => "Group 2")
      @user.groups << @group_1
      @user.groups << @group_2
    end
    it "should return false if group_id not in group_ids" do
      @user.member_of?(Factory(:group)).should be_false
    end
    it "should return true if group_id in group_ids" do
      @user.member_of?(@group_1).should be_true
    end
    it "should return false if not a group" do
      @user.member_of?(mock(Object, :id => @group_1.id)).should be_false
    end
  end
end
