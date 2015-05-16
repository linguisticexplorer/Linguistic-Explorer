require 'spec_helper'

describe Membership do
  describe "one-liners" do
    it { expect validate_presence_of :group }
    it { expect validate_presence_of :member }
    it { expect validate_presence_of :level }
    it { expect validate_uniqueness_of(:member_id).scoped_to(:group_id) }
    it { expect validate_inclusion_of(:level).in_array(Membership::ACCESS_LEVELS) }
    it { expect belong_to :member }
    it { expect belong_to :group }
  end

  describe "createable with combinations" do
    it "should allow a new user and group to associate" do
      expect do
        Membership.create(:member_id => FactoryGirl.create(:user).id, :level => Membership::MEMBER) do |m|
          m.group = FactoryGirl.create(:group)
        end
      end.to change(Membership, :count).by(1)
    end

    it "should allow a new user and group to associate" do
      group = FactoryGirl.create(:group)
      user = FactoryGirl.create(:user)
      expect do
        Membership.create(:member_id => user.id, :level => Membership::MEMBER) do |m|
          m.group = group
        end
      end.to have(0).errors

      expect do
        Membership.create(:member_id => user.id, :level => Membership::ADMIN ) do |m|
          m.group = group
        end
      end.to have(1).errors_on(:member_id)
    end
  end

  describe 'group_admin?' do
    it "should return true only if level is 'admin'" do
      group = FactoryGirl.create(:group)
      user = FactoryGirl.create(:user)
      expect do
        Membership.create(:member => user, :level => Membership::ADMIN) do |m|
          m.group = group
        end.group_admin?
      end.to be_truthy
      
      expect do
        Membership.create(:member => user, :level => Membership::MEMBER) do |m|
          m.group = group
        end.group_admin?
      end.not_to be_truthy
    end
  end
end
