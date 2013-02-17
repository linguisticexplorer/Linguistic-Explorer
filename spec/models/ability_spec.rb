require 'spec_helper'
require 'cancan/matchers'

describe Ability do
  describe "::" do
    describe "Site Admins" do
      it "should be able to manage every object" do
        ability = Ability.new(FactoryGirl.create(:user, :access_level => "admin"))
        [ User, Ling, Property, Category, LingsProperty, Example, ExamplesLingsProperty, Group, Membership, Search ].each do |klass|
          ability.should be_able_to(:manage, klass )
        end
      end

      it "should be able to manage every object in the forum" do
        ability = Ability.new(FactoryGirl.create(:user, :access_level => "admin"))
        [ ForumGroup, Forum, Topic, Post ].each do |klass|
          ability.should be_able_to(:manage, klass )
        end
      end
    end

    describe "Visitors" do
      before { @visitor = Ability.new(nil) }

      it "should be able to register as a new user" do
        @visitor.should be_able_to(:create, User)
      end

      it "should not be able to see users" do
        @visitor.should_not be_able_to(:read, User)
      end

      it "should not be able to read private groups" do
        @group = FactoryGirl.create(:group, :name => "privy", :privacy => Group::PRIVATE)
        @visitor.should_not be_able_to(:read, @group)
      end

      it "should not be able to see private group data" do
        @group = FactoryGirl.create(:group, :name => "privy", :privacy => Group::PRIVATE)
        [ :ling, :category ].each do |model|
          instance = FactoryGirl.create(model, :group => @group)
          instance.group.private?.should be_true
          @visitor.should_not be_able_to(:read, instance)
        end
      end

      it "should be able to view public groups and their data" do
        @group = FactoryGirl.create(:group, :name => "pubs", :privacy => Group::PUBLIC)
        @group.private?.should be_false
        @visitor.should be_able_to(:read, @group)
        @visitor.should be_able_to(:read, FactoryGirl.create(:ling, :group => @group))
        @visitor.should be_able_to(:read, FactoryGirl.create(:category, :group => @group))
      end

      it "should not be able to save searches, even on visible groups" do
        @group = FactoryGirl.create(:group, :name => "pubs", :privacy => Group::PUBLIC)
        @visitor.should_not be_able_to(:create, FactoryGirl.create(:search, :group => @group))
      end

      describe "within Forum" do
        before do
          @forum_group_secret = FactoryGirl.create(:forum_group, :title => "Secret Group", :state => false)
          @forum_group_public = FactoryGirl.create(:forum_group, :title => "Public Group", :state => true)
        end
        it "should not be able to see secret forum group" do
          @visitor.should_not be_able_to(:read, @forum_group_secret)
        end

        it "should be able to see public forum group" do
          @visitor.should be_able_to(:read, @forum_group_public)
        end

        it "should not be able to see secret forum in a public group" do
          forum = FactoryGirl.create(:forum, :title => "Secret Forum", :state => false, :forum_group => @forum_group_public)
          @visitor.should_not be_able_to(:read, forum)
        end

        it "should not be able to see public forum in a secret group" do
          forum = FactoryGirl.create(:forum, :title => "Public Forum", :state => true, :forum_group => @forum_group_secret)
          @visitor.should_not be_able_to(:read, forum)
        end

        it "should not be able to see a topic in a secret forum" do
          forum = FactoryGirl.create(:forum, :title => "Secret Forum", :state => false, :forum_group => @forum_group_public)
          topic = FactoryGirl.create(:topic, :title => "Free topic", :forum => forum)
          @visitor.should_not be_able_to(:read, topic)
        end

        it "should not be able to see a topic in a secret forum group" do
          forum = FactoryGirl.create(:forum, :title => "Secret Forum", :state => true, :forum_group => @forum_group_secret)
          topic = FactoryGirl.create(:topic, :title => "Free topic", :forum => forum)
          @visitor.should_not be_able_to(:read, topic)
        end

        it "should be able to see a topic in a public forum" do
          forum = FactoryGirl.create(:forum, :title => "Public Forum", :state => true, :forum_group => @forum_group_public)
          topic = FactoryGirl.create(:topic, :title => "Free topic", :forum => forum)
          @visitor.should be_able_to(:read, topic)
        end

      end
    end

    describe "Logged in Users" do
      before do
        @user = FactoryGirl.create(:user, :access_level => "user")
        @logged = Ability.new(@user)
      end

      it "should be able to manage themselves" do
        @logged.should be_able_to(:manage, @user)
      end

      it "should not be able to manage other users" do
        @logged.should_not be_able_to(:manage, FactoryGirl.create(:user, :name => "otherguy", :email => "other@example.com"))
      end

      describe "within Forum" do
        before do
          @forum_group_secret = FactoryGirl.create(:forum_group, :title => "Secret Group", :state => false)
          @forum_group_public = FactoryGirl.create(:forum_group, :title => "Public Group", :state => true)
        end

        it "should not be able to see secret forum group" do
          @logged.should_not be_able_to(:read, @forum_group_secret)
        end

        it "should be able to see public forum group" do
          @logged.should be_able_to(:read, @forum_group_public)
        end

        it "should not be able to see secret forum in a public group" do
          forum = FactoryGirl.create(:forum, :title => "Public Forum", :state => false, :forum_group => @forum_group_public)
          @logged.should_not be_able_to(:read, forum)
        end

        it "should not be able to see public forum in a secret group" do
          forum = FactoryGirl.create(:forum, :title => "Public Forum", :state => true, :forum_group => @forum_group_secret)
          @logged.should_not be_able_to(:read, forum)
        end

        it "should not be able to see a topic in a secret forum" do
          forum = FactoryGirl.create(:forum, :title => "Secret Forum", :state => false, :forum_group => @forum_group_public)
          topic = FactoryGirl.create(:topic, :title => "Free topic", :user => @user, :forum => forum)
          @logged.should_not be_able_to(:read, topic)
        end

        it "should not be able to see a topic in a secret forum group" do
          forum = FactoryGirl.create(:forum, :title => "Public Forum", :state => true, :forum_group => @forum_group_secret)
          topic = FactoryGirl.create(:topic, :title => "Free topic", :user => @user, :forum => forum)
          @logged.should_not be_able_to(:read, topic)
        end

        it "should be able to see a topic in a public forum" do
          forum = FactoryGirl.create(:forum, :title => "Public Forum", :state => true, :forum_group => @forum_group_public)
          topic = FactoryGirl.create(:topic, :title => "Free topic", :user => @user, :forum => forum)
          @logged.should be_able_to(:read, topic)
        end

        it "should be able to reply to a post in a public forum" do
          forum = FactoryGirl.create(:forum, :title => "Public Forum", :state => true, :forum_group => @forum_group_public)
          topic = FactoryGirl.create(:topic, :title => "Free topic", :user => @user, :forum => forum)
          @logged.should be_able_to(:create, topic.posts.new)
        end

        it "should be able to update his own post in a public forum" do
          forum = FactoryGirl.create(:forum, :title => "Public Forum", :state => true, :forum_group => @forum_group_public)
          topic = FactoryGirl.create(:topic, :title => "Free topic", :user => @user, :forum => forum)
          @logged.should be_able_to(:update, topic.posts.first)
        end

        it "should be able to destroy his own post in a public forum" do
          forum = FactoryGirl.create(:forum, :title => "Public Forum", :state => true, :forum_group => @forum_group_public)
          topic = FactoryGirl.create(:topic, :title => "Free topic", :user => @user, :forum => forum)
          @logged.should be_able_to(:destroy, topic.posts.first)
        end

        it "should not be able to update a post in a locked topic" do
          forum = FactoryGirl.create(:forum, :title => "Public Forum", :state => true, :forum_group => @forum_group_public)
          topic = FactoryGirl.create(:topic, :title => "Free topic", :locked => true, :user => @user, :forum => forum)
          @logged.should_not be_able_to(:update, topic.posts.first)
        end
      end
    end

    describe "Group Admins" do
      Group::PRIVACY.each do |privacy|
        describe "on a #{privacy} group they administrate" do
          before do
            @group = FactoryGirl.create(:group, :privacy => privacy)
            if Group::PRIVATE == privacy
              @group.private?.should be_true
            elsif Group::PUBLIC == privacy
              @group.private?.should be_false
            end
            @user  = FactoryGirl.create(:user)
            Membership.create(:group => @group, :member => @user, :level => Membership::ADMIN)
            @user.reload
            @admin = Ability.new(@user)
          end

          it "should be able to manage it" do
            @admin.should be_able_to(:manage, @group)
          end

          [ Ling, Category, Example, Membership ].each do |klass| # Property, LingsProperty, ExamplesLingsProperty removed due to more commplex creation requirements
            it "should be able to manage the group's #{klass.to_s.pluralize}" do
              instance = klass.new do |k|
                k.group = @group
                k.creator = @user
              end
              @admin.should be_able_to(:manage, instance)
            end
          end

          it "should be able to manage their own searches" do
            @admin.should be_able_to(:manage, FactoryGirl.create(:search, :group => @group, :creator => @user))
          end
        end
      end

      describe "looking at another public group" do
        before do
          group  = FactoryGirl.create(:group)
          @user   = FactoryGirl.create(:user)
          Membership.create(:group => group, :member => @user, :level => Membership::ADMIN)
          @user.reload
          @admin = Ability.new(@user)
          @other_group = FactoryGirl.create(:group, :name => "openness", :privacy => Group::PUBLIC)
          @other_group.private?.should be_false
        end

        it "should be able to read the group" do
          @admin.should be_able_to(:read, @other_group)
        end

        it "should be able to manage their own searches on the group" do
          @admin.should be_able_to(:manage, FactoryGirl.create(:search, :group => @other_group, :creator => @user))
        end

        [ Ling, Category, Example, Membership ].each do |klass| # LingsProperty, ExamplesLingsProperty, Property removed due to creation difficulty
          it "should be able to read the group's #{klass.to_s.capitalize.pluralize}" do
            instance = klass.create(:group => @other_group)
            @admin.should be_able_to(:read, instance)
          end
        end

        [:update, :create, :destroy ].each do |action|
          it "should not be able to :{action} them" do
            @admin.should_not be_able_to(action, @other_group)
          end

          [ Ling, Category, Example, Membership ].each do |klass| # Property, LingsProperty, ExamplesLingsProperty removed due to creation difficulty
            it "should not be able to perform :#{action} on #{klass.to_s.capitalize}" do
              instance = klass.new do |k|
                k.group = @other_group
                k.creator = @user
              end
              @admin.should_not be_able_to(action, instance)
            end
          end
        end

      end

      describe "with a private group that they are not a member of" do
        before do
          group  = FactoryGirl.create(:group)
          user   = FactoryGirl.create(:user)
          Membership.create(:group => group, :member => user, :level => Membership::ADMIN)
          user.reload
          @admin = Ability.new(user)
          @other_group = FactoryGirl.create(:group, :name => "haters", :privacy => Group::PRIVATE)
          @other_group.private?.should be_true
        end

        it "should not be able to search on the group" do
          instance = Search.new do |s|
            s.group = @other_group
            s.creator = @user
          end
          @admin.should_not be_able_to(:create, instance)
        end

        [ :read, :update, :create, :destroy ].each do |action|
          it "should not be able to :#{action} the group" do
            @admin.should_not be_able_to(action, @other_group)
          end

          [ Ling, Category, Example, Membership ].each do |klass| # Property, LingsProperty, ExamplesLingsProperty removed due to creation difficulty
            it "should not be able to perform :#{action} on #{klass.to_s.capitalize}" do
              instance = klass.new do |k|
                k.group = @other_group
                k.creator = @user
              end
              @admin.should_not be_able_to(action, instance)
            end
          end
        end
      end
    end

    describe "Group Members" do
      Group::PRIVACY.each do |privacy|
        describe "on a #{privacy} group they are a member of" do
          before do
            @group = FactoryGirl.create(:group, :privacy => privacy)
            if Group::PRIVATE == privacy
              @group.private?.should be_true
            elsif Group::PUBLIC == privacy
              @group.private?.should be_false
            end
            @user = FactoryGirl.create(:user)
            @membership = Membership.create(:group => @group, :member => @user, :level => Membership::MEMBER)
            @user.reload
            @member = Ability.new(@user)
          end

          it "should be able to read the group" do
            @member.should be_able_to(:read, @group)
            @member.should_not be_able_to(:create, @group)
            @member.should_not be_able_to(:update, @group)
            @member.should_not be_able_to(:destroy, @group)
          end

          it "should be able to manage their own searches" do
            @member.should be_able_to(:manage, FactoryGirl.create(:search, :group => @group, :creator => @user))
          end

          it "should not be able to manage the searches of others" do
            @member.should_not be_able_to(:manage, FactoryGirl.create(:search, :group => @group, :creator => FactoryGirl.create(:user, :email => "foonique@bar.com")))
          end

          [ ExamplesLingsProperty, LingsProperty, Example ].each do |klass|
            it "should be able to manage #{klass.to_s.pluralize} in their groups" do
              instance = klass.new do |k|
                k.group = @group
                k.creator = @user
              end
              @member.should be_able_to(:manage, instance)
            end
          end

          [ Ling, Property, Category ].each do |klass|
            it "should only be able to read the group and its #{klass.to_s.pluralize}" do
              instance = klass.new do |k|
                k.group = @group
                k.creator = @user
              end
              @member.should      be_able_to(:read,   instance)
              @member.should_not  be_able_to(:create, instance)
              @member.should_not  be_able_to(:update, instance)
              @member.should_not  be_able_to(:destroy, instance)
            end
          end

          it "should only be able to read and delete their own memberships" do
            @member.should      be_able_to(:read,   @membership)
            @member.should      be_able_to(:destroy, @membership)
            @member.should_not  be_able_to(:create,  Membership.new(:member => @user, :group => @group))
            @member.should_not  be_able_to(:update, @membership)
          end
        end
      end
    end

    describe "Non-Groupmembers" do
      before do
        @user = FactoryGirl.create(:user)
        @nonmember = Ability.new(@user)
      end

      it "should be able to manage their own searches on public groups" do
        @group = groups(:inclusive)
        @group.privacy.should == Group::PUBLIC
        @nonmember.should be_able_to(:manage, FactoryGirl.create(:search, :group => @group, :creator => @user))
      end

      it "should not be able to search on private groups" do
        @group = groups(:exclusive)
        @group.privacy.should == Group::PRIVATE
        @nonmember.should_not be_able_to(:manage, FactoryGirl.create(:search, :group => @group, :creator => @user))
      end

      it "should only be able to read public group data" do
        [ lings(                     :level0     ),
          properties(                :level0     ),
          categories(                :inclusive0 ),
          examples(                  :inclusive  ),
          examples_lings_properties( :inclusive  ),
          lings_properties(          :inclusive  )
        ].each do |data|
          data.group = groups(:inclusive)
          @nonmember.should     be_able_to(:read,   data)
          @nonmember.should_not be_able_to(:create, data)
          @nonmember.should_not be_able_to(:update, data)
          @nonmember.should_not be_able_to(:destroy, data)
        end
      end

      [ :create, :read, :update, :destroy ].each do |action|
        it "should not be able to :#{action} private group data" do
          [ lings(            :exclusive0),
            properties(       :exclusive0),
            categories(       :exclusive0),
            examples(         :exclusive ),
            examples_lings_properties(:exclusive),
            lings_properties( :exclusive )
          ].each do |data|
            data.should be_present
            data.group.should == groups(:exclusive)
            data.group.private?.should be_true
            @nonmember.can?(action, data.group).should be_false
            @nonmember.can?(action, data).should be_false
          end
        end
      end
    end
  end
end
