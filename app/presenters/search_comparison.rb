class SearchComparison
  include ERB::Util

  TYPES = [
    UNION         = :union,
    INTERSECTION  = :intersection,
    DIFFERENCE    = :difference,
    EXCLUSION     = :exclusion
  ]

  OPERATIONS = {
    UNION         => :+,
    INTERSECTION  => :&,
    DIFFERENCE    => :-,
    EXCLUSION     => :^
  }

  def self.model_name
    "SearchComparison"
  end

  attr_accessor :searches, :creator, :group, :type, :of_id, :with_id, :result_rows
  attr_reader :results

  def initialize(opts = {})
    set_attrs(opts || {})
    yield self if block_given?
  end

  def comparison_options
    TYPES.map { |c| [c, c] }
  end

  def search_options
    searches.map { |s| [h(s.name), s.id] }
  end

  def searches
    @searches ||= Search.where(:creator => creator, :group => group)
  end

  def enough_to_compare?
    searches.size > 1
  end

  def of
    @of   ||= Search.find(@of_id) unless @of_id.nil?
  end

  def with
    @with ||= Search.find(@with_id) unless @with_id.nil?
  end

  def search
    @search ||= build_search_through_comparison
  end

  private

  def build_search_through_comparison
    result_rows = compare_sets of.result_rows, with.result_rows

    Search.new do |s|
      s.creator     = creator
      s.group       = group
      s.result_rows = result_rows

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

  def compare_sets(results_1, results_2)
    set_1 = Set.new(results_1)
    set_2 = Set.new(results_2)
    op    = OPERATIONS[self.type.to_sym]
    set_1.send(op, set_2).to_a
  end
end
