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

  INCLUDED_TO_ATTRS = {
    :ling_0 => :ling_id,
    :property_0 => :property_id,
    :value_0 => :value,
    :example_0 => :example_ids,
    :ling_1 => :ling_id,
    :property_1 => :property_id,
    :value_1 => :value,
    :example_1 => :example_ids
  }

  def self.model_name
    "SearchComparison"
  end

  attr_accessor :searches, :creator, :group, :type, :of_id, :with_id, :result_rows, :include
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

  def save
    return false unless type.present? && of_id.present? && with_id.present?
    search
  end

  def search
    @search ||= build_search_through_comparison
  end

  private

  def included_columns
    @included_columns ||= @include.dup.symbolize_keys.keys
  end

  def parent_attrs
    included_columns.select { |key| key =~ /#{Depth::PARENT}/}.map { |col| INCLUDED_TO_ATTRS[col] }
  end

  def child_attrs
    included_columns.select { |key| key =~ /#{Depth::CHILD}/}.map { |col| INCLUDED_TO_ATTRS[col] }
  end

  def updated_of_query
    query = of.query || {}
    query["include"] = @include
    query
  end

  def build_search_through_comparison
    result_rows = compare_sets of.result_rows(parent_attrs, child_attrs), with.result_rows(parent_attrs, child_attrs)

    Search.new do |s|
      s.creator     = creator
      s.group       = group
      s.result_rows = result_rows

      # Set query from "of" search as basis for comparison
      # Needed to determined included columns for results
      # TODO save as separate column
      s.query = updated_of_query
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
