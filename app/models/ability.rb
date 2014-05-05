class Ability
  include CanCan::Ability

  def initialize(user)
    group_member_data = [Example, LingsProperty, ExamplesLingsProperty]
    group_admin_data  = [Ling, Property, Category, Membership]
    group_data = group_admin_data + group_member_data

    # ensure there is a user object in the not logged in case
    user ||= User.new

    if user.admin?
      can :manage, :all
    else
      # New users should be able to sign up, logged in users should be able to manage themselves
      user.new_record? ? can(:create, User) : can(:manage, user)
      # turn on reading for public groups and data
      can     :read,   Group,                   :privacy => Group::PUBLIC
      can     :read,   group_data, :group => {  :privacy => Group::PUBLIC }

      # turn on full data management for group admins
      can     :manage, Group, :memberships => { :member_id => user.id, :level => Membership::ADMIN }
      can     :manage, group_data,              :group_id => user.administrated_groups.map(&:id)
      # turn on group reading for members
      can     :read,   Group, :memberships => { :member_id => user.id }
      # turn on group member data management and all data reading for group members
      can     :manage, group_member_data,       :group_id => user.group_ids
      can     :read,   group_data,              :group_id => user.group_ids
      # turn on own membership deletion
      can     :destroy, Membership,             :member_id => user.id
      
      # turn on custom search authorization method
      can :manage, Search do |search|
        search.is_manageable_by?(user)
      end
      can :manage, SearchComparison do |sc|
        sc.searches.all? {|s| s.is_manageable_by?(user)}
      end

      # turn on all searches advanced features
      can :search, Search,        :group => { :privacy => Group::PUBLIC }
      can :cross, Search,         :group => { :privacy => Group::PUBLIC }
      can :mapping, Search,       :group => { :privacy => Group::PUBLIC }

      # turn on forum capabilities
      can :read, ForumGroup, :state => true
      can :read, Forum, :state => true, :forum_group => { :state => true }
      can :read, Topic, :forum => { :state => true, :forum_group => { :state => true } }
      can :read, Post, :topic => { :forum => { :state => true, :forum_group => { :state => true } } }

      can :update, Post, :user_id => user.id, :topic => { :locked => false }
      can :destroy, [Topic,Post], :user_id => user.id, :topic => { :locked => false }

      can :create, Post, :topic => { :locked => false } unless user.new_record?
      can :create, Topic unless user.new_record?
    end
  end
end
