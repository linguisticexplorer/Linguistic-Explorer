require 'spec_helper'

describe User do
  before(:each) do
    @user = User.new
  end

  describe "one-liners" do
    # it_should_validate_presence_of :name, :email, :access_level
    # it_should_have_many :memberships, :groups, :searches
    it { expect validate_presence_of :name }
    it { expect validate_presence_of :email }
    it { expect validate_presence_of :access_level }
    it { expect have_many :memberships }
    it { expect have_many :groups }
    it { expect have_many :searches }
  end

  describe "createable with combinations" do
    it "should allow sane looking names and passwords, and require access_level and email after the fact" do
      u = User.new(:name => "FIXME", :password => "password")
      u.email = "FIXME@FiX.com"
      u.access_level = "user"
      u.bypass_humanizer = true
      u.save!
      expect(u).not_to be_new_record
    end
  end

  describe "#admin?" do
    it "should be truthy only if the user has access_level of admin" do
      expect(FactoryGirl.create(:user, :email => "one@example.com", :access_level => "admin").admin?).to be_truthy
      expect(FactoryGirl.create(:user, :email => "two@example.com", :access_level => "not").admin?).not_to be_truthy
    end
  end

  describe "#administrated_groups" do
    it "should return the set of groups for which a user is an admin" do
      user = FactoryGirl.create(:user, :email => "one@example.com", :access_level => "user")
      group = FactoryGirl.create(:group)

      Membership.create(:level => "admin", :group => group, :member => user)
      expect(user.administrated_groups).to include(group)
    end
  end

  describe "reached_max_search_limit?" do
    it "should return reached max limit for search by group" do
      group = double(Group)
      expect(Search).to_receive(:reached_max_limit?).with(@user, group).and_return(true)
      expect(@user.reached_max_search_limit?(group)).to be_truthy
    end
    it "should return reached max limit for search by group" do
      allow(Search).to receive_message_chain(:reached_max_limit?).and_return(false)
      expect(@user.reached_max_search_limit?(double(Group))).to be_falsey
    end
  end

  describe "member_of?" do
    before(:each) do
      @group_1 = FactoryGirl.create(:group, :name => "Group 1")
      @group_2 = FactoryGirl.create(:group, :name => "Group 2")
      @user.groups << @group_1
      @user.groups << @group_2
    end
    it "should return false if group_id not in group_ids" do
      expect(@user.member_of?(FactoryGirl.create(:group))).to be_falsey
    end
    it "should return true if group_id in group_ids" do
      expect(@user.member_of?(@group_1)).to be_truthy
    end
    it "should return false if not a group" do
      expect(@user.member_of?(double(Object, :id => @group_1.id))).to be_falsey
    end
  end
end
