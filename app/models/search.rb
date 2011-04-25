class Search < ActiveRecord::Base
  MAX_SEARCH_LIMIT = 25

  include SearchForm
  include SearchResults
  include JsonAccessible

  belongs_to :group
  belongs_to :creator, :class_name => "User"

  validates_presence_of :creator, :group, :name
  validate :creator_not_over_search_limit

  serialize :query
  serialize :parent_ids
  serialize :child_ids

  json_accessor :query, :parent_ids, :child_ids

  class << self
    def reached_max_limit?(creator, group)
      where(:creator => creator, :group => group).count >= MAX_SEARCH_LIMIT
    end
  end

  private

  def creator_not_over_search_limit
    errors[:base] << "Max save limit (25) has been reached. Please remove old searches first" if group && creator && self.class.reached_max_limit?(creator, group)
  end
end
