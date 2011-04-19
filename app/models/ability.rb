class Ability
  include CanCan::Ability

  def initialize(user)
    group_member_data = [Example, LingsProperty, ExamplesLingsProperty]
    group_admin_data = [Ling, Property, Category, Membership]
    group_data = group_admin_data + group_member_data

    # ensure there is a user object in the not logged in case
    user ||= User.new

    if user.admin?
      can :manage, :all
    else
      # New users should be able to sign up, logged in users should be able to manage themselves
      user.new_record? ? can(:create, User) : can(:manage, user)

      # turn off private groups and data
      cannot  :manage,  Group,                 :privacy => "private"
      cannot  :manage,  group_data, :group => {:privacy => "private"}

      # turn on group reading for members and management for member admins
      can :read,    Group, :memberships => { :user_id => user.id, :level => 'member' }
      can :manage,  Group, :memberships => { :user_id => user.id, :level => 'admin' }

      # turn on group member data management and admin data reading for group members
      can :manage,  group_member_data,  :group => { :id => user.group_ids }
      can :read,    group_admin_data,   :group => { :id => user.group_ids }

      # turn on group data for group admins
      can :manage, Group,       :id => user.administrated_groups.map(&:id)
      can :manage, group_data,  :group => { :id => user.administrated_groups.map(&:id) }

      # turn on own membership deletion
      can :delete, Membership,  :user_id => user.id

      # turn on public group reading
      can :read, Group,                 :privacy => "public"
      can :read, group_data, :group => {:privacy => "public"}

      # TODO replace authentication check with CanCan solution
      # can :manage Search,     :group => { :privacy => 'public' }, :user => user
      # can :manage Search,     :group => { :id => user.group_ids }, :user => user
    end
  end
end
