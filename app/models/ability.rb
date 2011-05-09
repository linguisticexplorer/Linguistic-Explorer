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

      can :search, Search, :group => { :privacy => Group::PUBLIC }

      can :manage, SearchComparison do |sc|
        sc.searches.all?{|s| s.is_manageable_by?(user)}
      end
    end
  end
end
