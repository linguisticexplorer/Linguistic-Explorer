class Search < ActiveRecord::Base
  include SearchForm
  include SearchResults
  include JsonAccessible

  belongs_to :group
  belongs_to :user

  validates_presence_of :user, :group, :name
  validate :user_has_permission

  serialize :query
  serialize :parent_ids
  serialize :child_ids

  json_accessor :query, :parent_ids, :child_ids

  MAX_SEARCH_LIMIT = 25

  class << self
    def reached_max_limit?(user, group)
      where(:user => user, :group => group).count >= MAX_SEARCH_LIMIT
    end
  end

  private

  def user_has_permission
    return unless group && user

    if self.class.reached_max_limit?(user, group)
      errors[:base] << "Max save limit (25) has been reached. Please remove old searches first"
    end

    if group.private? && !user.member_of?(group)
      errors[:base] << "You must be a member of the group to use its search features"
    end
  end
end