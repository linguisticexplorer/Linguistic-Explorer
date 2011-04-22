class Membership < ActiveRecord::Base
  ACCESS_LEVELS = [
    ADMIN = "admin",
    MEMBER = "member"
  ]

  include Groupable

  validates_presence_of :user, :level
  validates_existence_of :user
  validates_uniqueness_of :user_id, :scope => :group_id
  validates_inclusion_of :level, :in => ACCESS_LEVELS

  belongs_to :user

  def group_admin?
    level == ADMIN
  end
end
