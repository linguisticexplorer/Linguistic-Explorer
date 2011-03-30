require 'spec_helper'
require 'cancan/matchers'

describe Ability do
  describe ":: Site Admins" do
    it "should be able to manage every object" do
      ability = Ability.new(Factory(:user, :access_level => "admin"))
      [ User, Ling, Property, Category, LingsProperty, Example, Group, Membership ].each do |klass|
        ability.should be_able_to(:manage, klass )
      end
    end
  end

  describe ":: Visitors" do
    before { @visitor = Ability.new(nil) }

    it "should be able to register as a new user" do
      @visitor.should be_able_to(:create, User)
    end

    it "should not be able to see users" do
      @visitor.should_not be_able_to(:read, User)
    end

    it "should not be able to see private groups and their data" do
      @group = Factory(:group, :name => "privy", :privacy => "private")
      [ :ling, :category ].each do |model|
        @visitor.should_not be_able_to(:read, Factory(model, :group => @group))
      end
    end

    it "should be able to view public groups and their data" do
      @group = Factory(:group, :name => "pubs", :privacy => "public")
      @visitor.should be_able_to(:read, Factory(:ling, :group => @group))
      @visitor.should be_able_to(:read, Factory(:category, :group => @group))
    end
  end

  describe ":: Logged in Users" do
    before do
      @user = Factory(:user, :name => "bob", :access_level => "user")
      @logged = Ability.new(@user)
    end

    it "should be able to manage themselves" do
      @logged.should be_able_to(:manage, @user)
    end

    it "should not be able to manage other users" do
      @logged.should_not be_able_to(:manage, Factory(:user, :name => "otherguy", :email => "other@example.com"))
    end
  end

  describe ":: Group Admins" do
    it "should be able to manage their group and all data within it" do
      @group = Factory(:group)
      user   = Factory(:user)
      @admin = Ability.new(user)
      Membership.create(:group => @group, :user => user, :level => "admin")

      @admin.should be_able_to(:manage, @group)
      [ Ling, Property, Category, LingsProperty, Example, Membership ].each do |klass|
        @admin.should be_able_to(:manage, klass)
      end
    end
  end

  describe ":: Group Members" do
    before do
      @group  = Factory(:group)
      user    = Factory(:user)
      @member = Ability.new(user)
      @membership = Membership.create(:group => @group, :user => user, :level => "member")
    end

    it "should be able to manage examples, LPVs, ELPVs in their groups" do
      [ LingsProperty, Example ].each { |klass| @member.should be_able_to(:manage, klass) }
    end

    it "should only be able to read the group and its lings, properties, categories" do
      [ Ling, Property, Category ].each do     |klass|
        @member.should      be_able_to(:read,   klass)
        @member.should_not  be_able_to(:create, klass)
        @member.should_not  be_able_to(:update, klass)
        @member.should_not  be_able_to(:delete, klass)
      end
    end

    it "should only be able to read delete their own memberships" do
      @member.should      be_able_to(:delete, @membership)
      @member.should      be_able_to(:read,   @membership)
      @member.should_not  be_able_to(:create,  Membership)
      @member.should_not  be_able_to(:update, @membership)
    end
  end

  describe ":: Non-Groupmembers" do
    before { @nonmember = Ability.new(Factory(:user)) }

    it "should only be able to read public group data" do
      [ lings(            :level0    ),
        properties(       :level0    ),
        categories(       :inclusive0),
        examples(         :inclusive ),
        lings_properties( :inclusive )
      ].each do |data|
        @nonmember.should     be_able_to(:read,   data)
        @nonmember.should_not be_able_to(:update, data)
        @nonmember.should_not be_able_to(:delete, data)
      end
    end

    [ :read, :update, :delete ].each do |action|
      it "should not be able to :#{action} private group data" do
        [ lings(            :exclusive0),
          properties(       :exclusive0),
          categories(       :exclusive0),
          examples(         :exclusive ),
          lings_properties( :exclusive )
        ].each { |data| @nonmember.should_not be_able_to(action, data) }
      end
    end
  end
end
