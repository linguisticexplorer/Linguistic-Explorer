class Membership < ActiveRecord::Base
  include Groupable

  validates_presence_of :user, :level
  validates_existence_of :user
  validates_uniqueness_of :user_id, :scope => :group_id

  belongs_to :user

  def group_admin?
    'admin' == level
  end
end
