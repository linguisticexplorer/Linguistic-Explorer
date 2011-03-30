require 'spec_helper'
require 'cancan/matchers'

describe Ability do
  describe "::Site Admins" do
    it "should be able to manage every object" do
      ability = Ability.new(Factory(:user, :access_level => "admin"))
      [ User, Ling, Property, Category, LingsProperty, Example, Group, Membership ].each do |klass|
        ability.should be_able_to(:manage, klass )
      end
    end
  end

  describe "::Visitors" do
    before { @visitor = Ability.new(nil) }

    it "should be able to register as a new user" do
      @visitor.should be_able_to(:create, User)
    end

    it "should not be able to see users" do
      @visitor.should_not be_able_to(:read, User)
    end

    it "should not be able to see private groups and their data" do
      @group = Factory(:group, :name => "privy", :privacy => "private")
      @visitor.should_not be_able_to(:read, @group)
      [ :ling, :category ].each do |model|
        @visitor.should_not be_able_to(:read, Factory(model, :group => @group))
      end
    end

    it "should be able to view public groups and their data" do
      @group = Factory(:group, :name => "pubs", :privacy => "public")
      @visitor.should be_able_to(:read, @group)
      @visitor.should be_able_to(:read, Factory(:ling, :group => @group))
      @visitor.should be_able_to(:read, Factory(:category, :group => @group))
    end
  end

  describe "::Logged in Users" do
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

  describe "::Group Admins" do
    describe "on their own group" do
      before do
        @group = Factory(:group)
        user   = Factory(:user)
        @admin = Ability.new(user)
        Membership.create(:group => @group, :user => user, :level => "admin")
      end

      it "should be able to manage it" do
        @admin.should be_able_to(:manage, @group)
      end

      [ Ling, Category, Example, Membership ].each do |klass| # Property, LingsProperty removed due to more commplex creation requirements
        it "should be able to manage the group's #{klass.to_s.pluralize}" do
          instance = klass.create(:group => @group)
          @admin.should be_able_to(:manage, instance)
        end
      end
    end

    describe "looking at another public group" do
      before do
        group  = Factory(:group)
        user   = Factory(:user)
        @admin = Ability.new(user)
        Membership.create(:group => group, :user => user, :level => "admin")
        @other_group = Factory(:group, :name => "openness", :privacy => "public")
      end

      it "should not be able to read the group" do
        @admin.should be_able_to(:read, @other_group)
      end

      [ Ling, Category, Example, Membership ].each do |klass| # LingsProperty, Property removed due to creation difficulty
        it "should be able to read the group's #{klass.to_s.capitalize.pluralize}" do
          instance = klass.create(:group => @other_group)
          @admin.should be_able_to(:read, instance)
        end
      end

      [:update, :create, :destroy ].each do |action|
        it "should not be able to :{action} them" do
          @admin.should_not be_able_to(action, @other_group)
        end

        [ Ling, Category, Example, Membership ].each do |klass| # Property, LingsProperty removed due to creation difficulty
          it "should not be able to perform :#{action} on #{klass.to_s.capitalize}" do
            instance = klass.create(:group => @other_group)
            @admin.should_not be_able_to(action, instance)
          end
        end
      end
    end

    describe "looking at another private group" do
      before do
        group  = Factory(:group)
        user   = Factory(:user)
        @admin = Ability.new(user)
        Membership.create(:group => group, :user => user, :level => "admin")
        @other_group = Factory(:group, :name => "haters", :privacy => "private")
      end

      [ :read, :update, :create, :destroy ].each do |action|
        it "should not be able to :{action} them" do
          @admin.should_not be_able_to(action, @other_group)
        end

        [ Ling, Category, Example, Membership ].each do |klass| # Property, LingsProperty removed due to creation difficulty
          it "should not be able to perform :#{action} on #{klass.to_s.capitalize}" do
            instance = klass.create(:group => @other_group)
            @admin.should_not be_able_to(action, instance)
          end
        end
      end
    end
  end

  describe "::Group Members" do
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
      [ Ling, Property, Category ].each do |klass| #TODO notice that these classes are all not scoped to the group
        instance = klass.new(:group => @group)
        @member.should      be_able_to(:read,   instance)
        @member.should_not  be_able_to(:create, klass)
        @member.should_not  be_able_to(:update, instance)
        @member.should_not  be_able_to(:delete, instance)
      end
    end

    it "should only be able to read and delete their own memberships" do
      @member.should      be_able_to(:read,   @membership)
      @member.should      be_able_to(:delete, @membership)
      @member.should_not  be_able_to(:create,  Membership) #TODO needs to specify creating memberships misgrouped
      @member.should_not  be_able_to(:update, @membership)
    end
  end

  describe "::Non-Groupmembers" do
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
        ].each { |data| @nonmember.can?(action, data).should be_false }
      end
    end
  end
end
