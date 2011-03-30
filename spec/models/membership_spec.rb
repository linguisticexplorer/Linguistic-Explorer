require 'spec_helper'

describe Membership do
  describe "one-liners" do
    it_should_validate_presence_of :group, :user, :level
    it_should_validate_uniqueness_of :user_id, :scope => :group_id

    it_should_belong_to :user, :group
#    it_should_validate_existence_of :group, :user
  end

  describe "createable with combinations" do
    it "should allow a new user and group to associate" do
      should_be_createable :with => { :group_id => Factory(:group).id, :user_id => Factory(:user).id, :level => "editor" }
    end

    it "should allow a new user and group to associate" do
      group = Factory(:group)
      user = Factory(:user)
      Membership.create( :group_id => group.id, :user_id => user.id, :level => "editor" ).should have(0).errors
      Membership.create( :group_id => group.id, :user_id => user.id, :level => "admin" ).should have(1).errors_on(:user_id)
    end
  end

  describe 'group_admin?' do
    it "should return true only if level is 'admin'" do
      group = Factory(:group)
      user = Factory(:user)
      Membership.create(:group => group, :user => user, :level => "admin").group_admin?.should be_true
      Membership.create(:group => group, :user => user, :level => "member").group_admin?.should_not be_true
    end
  end
end
