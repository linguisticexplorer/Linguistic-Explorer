class Membership < ActiveRecord::Base
  ACCESS_LEVELS = [
    ADMIN = "admin",
    MEMBER = "member"
  ]

  include Groupable

  validates_presence_of :member, :level
  validates_existence_of :member
  validates_uniqueness_of :member_id, :scope => :group_id
  validates_inclusion_of :level, :in => ACCESS_LEVELS

  belongs_to :member, :class_name => "User", :foreign_key => :member_id

  def group_admin?
    ADMIN == level
  end
end
