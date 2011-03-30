require 'spec_helper'

describe User do
  describe "one-liners" do
    it_should_validate_presence_of :name, :email, :access_level
    it_should_have_many :memberships, :groups
  end

  describe "createable with combinations" do
    it "should allow sane looking names and passwords, and require access_level and email after the fact" do
      u = User.new(:name => "FIXME", :password => "password")
      u.email = "FIXME@FiX.com"
      u.access_level = "user"
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
      Membership.create(:level => "admin", :group => group, :user => user)
      user.administrated_groups.should include(group)
    end
  end
end
