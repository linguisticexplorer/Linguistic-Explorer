class Membership < ActiveRecord::Base
  rolify
  include CSVAttributes

  ACCESS_LEVELS = [
    ADMIN = "admin",
    MEMBER = "member"
  ]

  ROLES = [
    MODERATOR = "Moderator",
    EXPERT = "Linguistic Expert",
    AUTHOR = "Property Author"
  ]

  CSV_ATTRIBUTES = %w[ id member_id group_id level creator_id ]
  def self.csv_attributes
    CSV_ATTRIBUTES
  end

  include Groupable

  # validates_presence_of :member, :level
  # validates_existence_of :member
  validates :member, :presence => true, :existence => true
  validates :level, :presence => true
  # validates_uniqueness_of :member_id, :scope => :group_id
  validates :member_id, :uniqueness => {:scope => :group_id }
  validates_inclusion_of :level, :in => ACCESS_LEVELS + ROLES

  belongs_to :member, :class_name => "User", :foreign_key => :member_id

  def group_admin?
    ADMIN == level
  end
end
