class Ability
  include CanCan::Ability

  def initialize(user)
    group_member_data = [Example, LingsProperty, ExamplesLingsProperty]
    group_admin_data  = [Ling, Property, Category, Membership]

    # Doesn't need to have Example in this group.
    # If the user can edit a ling, he can also add, edit and remove examples
    group_expert_data = [Example, LingsProperty, ExamplesLingsProperty, Ling]

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
      # turn on group data reading for group members
      can     :read,   group_data,              :group_id => user.group_ids
      # Cannot scope to specific instances, but at least let experts only pass
      # The expert can't delete or create ling but it can update the ling is expert for
      can     :update, group_expert_data,       :group_id => user.is_expert_for_groups
      can     :create, Example,                 :group_id => user.is_expert_for_groups
      can     :create, ExamplesLingsProperty,       :group_id => user.is_expert_for_groups
      # turn on all searches advanced features
      can :search, Search,        :group => { :privacy => Group::PUBLIC }
      
      # turn on edit for experts
      # Member can manage things either assigned OR not assigned yet Resources
      # can [:define, :destroy] , group_expert_data if user.expert_of? resource

      # can :define , group_author_data, :id => user.properties_author
      # can :destroy, group_author_data, :id => user.properties_author

      # turn on own membership deletion
      can     :destroy, Membership,             :member_id => user.id

      # turn on custom search authorization method
      can :manage, Search do |search|
        search.is_manageable_by?(user)
      end

      can :manage, SearchComparison do |sc|
        sc.searches.all? {|s| s.is_manageable_by?(user)}
      end

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
