class SearchComparison
  include ERB::Util

  def self.model_name
    "SearchComparison"
  end

  attr_accessor :searches, :user, :group, :type, :of_id, :with_id, :parent_ids, :child_ids
  attr_reader :results

  def initialize(opts = {})
    set_attrs(opts || {})
    yield self if block_given?
  end

  def comparison_options
    %w[union].map { |c| [c, c] }
  end

  def search_options
    searches.map { |s| [h(s.name), s.id] }
  end

  def searches
    @searches ||= Search.where(:user => user, :group => group)
  end

  def enough_to_compare?
    searches.size > 1
  end

  def of
    @of ||= Search.find(@of_id) unless @of_id.nil?
  end

  def with
    @with ||= Search.find(@with_id) unless @with_id.nil?
  end

  def search
    @search ||= build_search_through_comparison
  end

  private

  def compare!
    # UNION
    self.parent_ids = (of.parent_ids + with.parent_ids).uniq
    self.child_ids  = (of.child_ids  + with.child_ids).uniq
  end

  def build_search_through_comparison
    compare!
    Search.new do |s|
      s.user        = user
      s.group       = group
      s.parent_ids  = parent_ids
      s.child_ids   = child_ids

      # Set query from "of" search as basis for comparison
      # Needed to determined included columns for results
      # TODO save as separate column
      s.query = of.query
    end
  end

  def set_attrs(opts)
    opts.each do |attribute, value|
      send("#{attribute}=", value)
    end
  end
end
