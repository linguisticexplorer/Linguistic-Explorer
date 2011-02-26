require 'spec_helper'

describe GroupMembership do
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
      GroupMembership.create( :group_id => group.id, :user_id => user.id, :level => "editor" ).should have(0).errors
      GroupMembership.create( :group_id => group.id, :user_id => user.id, :level => "admin" ).should have(1).errors_on(:user_id)
    end
  end
end
