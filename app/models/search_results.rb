module SearchResults
  include Enumerable
  include Comparisons

  # To add paginate method in Array class
  # https://github.com/mislav/will_paginate/wiki/Backwards-incompatibility
  require 'will_paginate/array'

  delegate :included_columns, :depth_of_cross_search, :to => :query_adapter

  def each
    results.each { |r| yield r }
  end

  def results(pagination=false)
    @results ||= begin
      ensure_result_groups!
      #Rails.logger.debug "Step 4 => #{self.class} - Rendering"
      ResultMapperBuilder.new(self.result_groups).to_flatten_results
    end
    # Rails.logger.debug "Step 4 => #{self.class} - Results Inspect:#{@results.inspect}"

    if pagination
      @results.paginate(:page => @offset, :per_page => ActiveRecord::Base.per_page)
    else
      @results
    end
  end

  def getType
    results if @result.nil?
    return self.result_groups["type"] || "default"
  end

  def default?
    results if @result.nil?
    !self.result_groups.key?("type")
  end

  def cross?
    results if @result.nil?
    self.result_groups["type"] == "cross"
  end

  def compare?
    results if @result.nil?
    self.result_groups["type"] == "compare"
  end

  def implication?
    results if @result.nil?
    kinds_of_implication.include? self.result_groups["type"]
  end

  def clustering?
    results if @result.nil?
    self.result_groups["type"] == "clustering_hamming"
  end

  def mappable?
    results.any? && mappable_kind? && !non_mappable_kind?
  end

  private

  def mappable_kind?
    default? || cross? || compare? || implication?
  end

  def non_mappable_kind?
    (clustering?) || self.search_comparison
  end

  def handle_old_serialization
    if self.query.is_a? String
      self.query = ActiveSupport::JSON.decode self.query
    end
  end

  def ensure_result_groups!

    # Keep it here for legacy instaces saved
    handle_old_serialization

    self.result_groups ||= build_result_groups(parent_and_child_lings_property_ids)
  end

  def parent_and_child_lings_property_ids
    ids = [self.parent_ids, self.child_ids].compact
    # Cache for saved searches
    return result_adapter(ids) if ids.any?
    result_adapter(filter_lings_property_ids_from_query)
  end

  def build_result_groups(result_adapter)
    ResultMapperBuilder.build_result_groups(result_adapter)
  end

  def filter_lings_property_ids_from_query
    SearchFilterBuilder.new(query_adapter).filtered_parent_and_child_ids
  end

  def query_adapter
    @query_adapter ||= QueryAdapter.new(self.group, self.query)
  end

  def result_adapter(result_ids)
    @result_adapter ||= ResultAdapter.new(query_adapter, result_ids)
  end

  def kinds_of_implication
    ["implication_both", "implication_ante", "implication_cons", "implication_double"]
  end

end