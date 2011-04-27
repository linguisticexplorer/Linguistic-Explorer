class Search < ActiveRecord::Base
  MAX_SEARCH_LIMIT = 25
  include Groupable
  include Extensions::Wheres

  include SearchForm
  include SearchResults
  include JsonAccessible

  validates_presence_of :creator, :name
  validate :creator_not_over_search_limit

  serialize :query
  # serialize :parent_ids
  # serialize :child_ids
  serialize :result_rows

  json_accessor :query, :result_rows

  scope :by, lambda { |creator| where(:creator => creator) }

  attr_accessor :parent_ids, :child_ids

  class << self
    def reached_max_limit?(creator, group)
      scoped.by(creator).in_group(group).count >= MAX_SEARCH_LIMIT
    end
  end

  def is_manageable_by?(user)
    user.id.present? && user == creator && Ability.new(user).can?(:read, group)
  end

  private

  def creator_not_over_search_limit
    errors[:base] << "Max save limit (#{MAX_SEARCH_LIMIT}) has been reached. Please remove old searches first" if group && creator && self.class.reached_max_limit?(creator, group)
  end
end
