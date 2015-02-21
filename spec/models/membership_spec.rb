require 'spec_helper'

describe Membership do
  describe "one-liners" do
    it { should validate_presence_of :group }
    it { should validate_presence_of :member }
    it { should validate_presence_of :level }
    it { should validate_uniqueness_of(:member_id).scoped_to(:group_id) }
    it { should validate_inclusion_of(:level).in_array(Membership::ACCESS_LEVELS) }
    it { should belong_to :member }
    it { should belong_to :group }
    # it_should_validate_presence_of :group, :member, :level
    # it_should_validate_uniqueness_of :member_id, :scope => :group_id
    # it_should_validate_inclusion_of :level, :in => Membership::ACCESS_LEVELS

    # it_should_belong_to :member, :group
  end

  describe "createable with combinations" do
    it "should allow a new user and group to associate" do
      lambda do
        Membership.create(:member_id => FactoryGirl.create(:user).id, :level => Membership::MEMBER) do |m|
          m.group = FactoryGirl.create(:group)
        end
      end.should change(Membership, :count).by(1)
    end

    it "should allow a new user and group to associate" do
      group = FactoryGirl.create(:group)
      user = FactoryGirl.create(:user)
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
      group = FactoryGirl.create(:group)
      user = FactoryGirl.create(:user)
      Membership.create(:member => user, :level => Membership::ADMIN) do |m|
        m.group = group
      end.group_admin?.should be_true

      Membership.create(:member => user, :level => Membership::MEMBER) do |m|
        m.group = group
      end.group_admin?.should_not be_true
    end
  end
end
