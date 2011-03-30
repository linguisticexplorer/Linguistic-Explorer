class Ability
  include CanCan::Ability

  def initialize(user)
    group_member_data = [Example, LingsProperty]
    group_admin_data = [Ling, Property, Category]
    group_data = group_admin_data + group_member_data

    user ||= User.new # guest user (not logged in)

    if user.admin?
      can :manage, :all
    else
      # New users should be able to sign up, logged in users should be able to manage themselves
      user.new_record? ? can(:create, User) : can(:manage, user)

      # any user can see all public groups and data
      can :read, Group, :privacy => "public"
      group_data.each{|gd| can :read, gd, :group => { :privacy => "public" } }
      # blanket coverage to hide private groups from users
      cannot :manage, Group, :privacy => "private"
      group_data.each{|gd| cannot :manage, gd, :group => { :privacy => "private" } }

      # turn on group reading for members and management for member admins
      can :read, Group, :memberships => { :user_id => user.id, :level => 'member' }
      can :manage, Group, :memberships => { :user_id => user.id, :level => 'admin' }

      # turn on group member data management for group members
      group_member_data.each{|gd| can :manage, gd, :group => { :id => user.group_ids } }
      # turn on group admin data reading for group members
      group_admin_data.each{|gd| can :read, gd, :group => { :id => user.group_ids } }

      # turn on group data for group admins
      can :manage, Group, :memberships => { :user_id => user.id, :level => "admin"}
      group_data.each{|gd| can :manage, gd, :group => { :id => user.administrated_groups.map(&:id) } }

      # explicity turn on membership permissions
      cannot [:create, :update], Membership # cannot create or update any
      can [:read, :delete], Membership, :user_id => user.id # can read and delete their own
      can :manage, Membership, :group => { :id => user.administrated_groups.map(&:id) } # can manage any in groups they admin
    end
  end
end
