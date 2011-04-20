module SearchResults
  include Enumerable

  delegate :included_columns, :to => :query_adapter

  def each
    results.each { |r| yield r }
  end

  def results
    @results ||= begin
      self.parent_ids, self.child_ids = filter_results_from_query if self.parent_ids.blank?
      ResultMapper.new(self.parent_ids, self.child_ids).to_results
    end
  end

  private

  def filter_results_from_query
    # Filters return depth_0_vals and depth_1_vals

    filter = filter_by_any_selected_lings_and_props

    filter = filter_by_keywords           filter, :ling

    filter = filter_by_keywords           filter, :property

    filter = filter_by_keywords           filter, :example

    filter = filter_by_val_query_params   filter

    filter = filter_by_depth_intersection filter

    filter = filter_by_all_conditions     filter, :property

    filter = filter_by_all_conditions     filter, :lings_property

    [filter.depth_0_ids, filter.depth_1_ids]
  end

  def query_adapter
    @query_adapter ||= QueryAdapter.new(self.group, self.query)
  end

  def filter_by_any_selected_lings_and_props
    SelectAnyFilter.new(query_adapter)
  end

  def filter_by_keywords(filter, strategy)
    KeywordFilter.new(filter, query_adapter) do |f|
      f.strategy = strategy
    end
  end

  def filter_by_val_query_params(filter)
    SelectValuePairsFilter.new(filter, query_adapter)
  end

  def filter_by_depth_intersection(filter)
    IntersectionFilter.new(filter, query_adapter)
  end

  def filter_by_all_conditions(filter, strategy)
    SelectAllFilter.new(filter, query_adapter) do |f|
      f.strategy = strategy
    end
  end

end