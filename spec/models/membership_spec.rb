require 'spec_helper'

describe Membership do
  describe "one-liners" do
    it_should_validate_presence_of :group, :member, :level
    it_should_validate_uniqueness_of :member_id, :scope => :group_id
    it_should_validate_inclusion_of :level, :in => Membership::ACCESS_LEVELS

    it_should_belong_to :member, :group
#    it_should_validate_existence_of :group, :user
  end

  describe "createable with combinations" do
    it "should allow a new user and group to associate" do
      lambda do
        Membership.create(:member_id => Factory(:user).id, :level => Membership::MEMBER) do |m|
          m.group = Factory(:group)
        end
      end.should change(Membership, :count).by(1)
    end

    it "should allow a new user and group to associate" do
      group = Factory(:group)
      user = Factory(:user)
      Membership.create(:member_id => user.id, :level => Membership::MEMBER) do |m|
        m.group = group
      end.should have(0).errors

      Membership.create(:member_id => user.id, :level => Membership::ADMIN ) do |m|
        m.group = group
      end.should have(1).errors_on(:member_id)
    end
  end

  describe 'group_admin?' do
    it "should return true only if level is 'admin'" do
      group = Factory(:group)
      user = Factory(:user)
      Membership.create(:member => user, :level => Membership::ADMIN) do |m|
        m.group = group
      end.group_admin?.should be_true

      Membership.create(:member => user, :level => Membership::MEMBER) do |m|
        m.group = group
      end.group_admin?.should_not be_true
    end
  end
end
