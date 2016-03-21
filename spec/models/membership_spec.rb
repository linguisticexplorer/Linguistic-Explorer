require 'rails_helper'

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
      expect(Membership.create(:member_id => user.id, :level => Membership::MEMBER) do |m|
          m.group = group
        end).to have(0).errors

      expect(Membership.create(:member_id => user.id, :level => Membership::ADMIN ) do |m|
          m.group = group
        end).to have(1).errors_on(:member_id)
    end
  end

  describe 'group_admin?' do
    it "should return true only if level is 'admin'" do
      group = FactoryGirl.create(:group)
      user = FactoryGirl.create(:user)
      expect(Membership.create(:member => user, :level => Membership::ADMIN) do |m|
          m.group = group
        end.group_admin?).to be_truthy
      
      expect(Membership.create(:member => user, :level => Membership::MEMBER) do |m|
          m.group = group
        end.group_admin?).not_to be_truthy
    end
  end

  def make_expert(level, group=nil, resource=nil)
    group ||= FactoryGirl.create(:group)
    resource ||= FactoryGirl.create(:ling, :name => "sample", :group => group )

    user = FactoryGirl.create(:user)
    @membership = Membership.create(:member => user, :level => level) do |m|
      m.group = group
    end

    @membership.add_expertise_in resource
  end

  describe "role" do

    it "should return 'expert' if any expertise is set" do
      make_expert(Membership::MEMBER)

      expect( @membership.role ).to eq("expert")
    end

    it "should return 'group admin' if the level is 'admin' no matter expertise" do
      make_expert(Membership::ADMIN)

      expect( @membership.role ).to eq("group admin")
    end
  end
  
  describe "is_expert?" do
    it "should return false is no expertise is set for a member" do
      membership = Membership.create(:member => FactoryGirl.create(:user), :level => Membership::MEMBER) do |m|
        m.group = FactoryGirl.create(:group)
      end

      expect( membership.is_expert? ).to_not be_truthy
    end

    it "should return false is no expertise is set for an admin" do
      membership = Membership.create(:member => FactoryGirl.create(:user), :level => Membership::ADMIN) do |m|
        m.group = FactoryGirl.create(:group)
      end

      expect( membership.is_expert? ).to_not be_truthy
    end

    it "should return true if an expertise is set" do
      make_expert(Membership::MEMBER)

      expect( @membership.is_expert? ).to be_truthy
    end

    it "should return true if an expertise is set to a admin" do
      make_expert(Membership::ADMIN)

      expect( @membership.is_expert? ).to be_truthy
    end
  end

  describe "add_expertise_in" do
    it "should make a member an expert for a given resource" do
      group = FactoryGirl.create(:group)
      ling = FactoryGirl.create(:ling, :name => "sample", :group => group )
      make_expert(Membership::MEMBER, group, ling)

      expect( @membership.has_role? :expert, ling  ).to be_truthy
    end
  end

  describe "remove_expertise_in" do
    it "should remove an expertise previously set" do
      group = FactoryGirl.create(:group)
      ling = FactoryGirl.create(:ling, :name => "sample", :group => group )

      make_expert(Membership::MEMBER, group, ling)

      expect( @membership.is_expert? ).to be_truthy

      @membership.remove_expertise_in ling
      expect( @membership.is_expert? ).to_not be_truthy
    end
  end

  describe "set_expertise_in" do
    it "should add a single expertise" do
      group = FactoryGirl.create(:group)
      membership = Membership.create(:member => FactoryGirl.create(:user), :level => Membership::MEMBER) do |m|
        m.group = group
      end

      lings = [FactoryGirl.create(:ling, :name => "sample", :group => group )]

      membership.set_expertise_in lings

      expect( membership.is_expert? ).to be_truthy
    end

    # it "should remove previously expertise and set only passed ones" do
    #   group = FactoryGirl.create(:group)
    #   user = FactoryGirl.create(:user)
    #   membership = Membership.create(:member => user, :level => Membership::MEMBER) do |m|
    #     m.group = group
    #   end

    #   prevLing = FactoryGirl.create(:ling, :name => "prevSample", :group => group )

    #   membership.add_expertise_in prevLing

    #   expect( membership.has_role? :expert, prevLing  ).to be_truthy

    #   lings = [FactoryGirl.create(:ling, :name => "sample", :group => group )]

    #   membership.set_expertise_in lings

    #   expect( membership.has_role? :expert, lings.first  ).to be_truthy

    #   # puts "DEBUG: #{membership.roles.inspect} - #{membership.has_role?(:expert, :any)} - #{membership.has_role?(:expert, prevLing)}"
    #   expect( membership.has_role? :expert, prevLing  ).to_not be_truthy
    # end
  end
end
