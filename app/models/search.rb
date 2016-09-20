class Search < ActiveRecord::Base
  MAX_SEARCH_LIMIT = 25

  # Thresholds
  RESULTS_CROSS_THRESHOLD = 6
  RESULTS_FLATTEN_THRESHOLD = 100000

  include Groupable
  include Concerns::Wheres

  include SearchForm
  include SearchResults
  include JsonAccessible

  validates_presence_of :creator, :name
  validate :creator_not_over_search_limit

  serialize :query, JSON
  serialize :result_groups, JSON

  json_accessor :query, :result_groups

  scope :by, lambda { |creator| where( :creator_id => creator.id ) }

  attr_accessor :parent_ids, :child_ids, :offset

  before_save :flush_result_groups!

  class << self
    def reached_max_limit?(creator, group)
      scoped.by(creator).in_group(group).count >= MAX_SEARCH_LIMIT
    end
  end

  def is_manageable_by?(user)
    user.id.present? && user.id == creator.id && Ability.new(user).can?(:read, group)
  end

  def get_valid_resource
    false
  end

  private

  def creator_not_over_search_limit
    errors[:base] << "Max save limit (#{MAX_SEARCH_LIMIT}) has been reached. Please remove old searches first" if group && creator && self.class.reached_max_limit?(creator, group)
  end
end
