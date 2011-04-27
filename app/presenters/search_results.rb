module SearchResults
  include Enumerable

  delegate :included_columns, :to => :query_adapter

  def each
    results.each { |r| yield r }
  end

  def results
    @results ||= begin
      self.result_rows = filter_results_from_query if self.result_rows.blank?
      ResultMapper.new(self.result_rows).to_results
    end
  end

  private

  def map_results(parent_ids, child_ids)

    if self.group.has_depth?
      children = LingsProperty.with_id(child_ids).includes([:ling, :property]).joins(:ling).
        order("lings.parent_id, lings.name")
      children.map do |child|
        parent_id = parent_ids.detect { |parent_id| child.parent_ling_id == parent_id }
        [parent_id, child.id]
      end
    else
      parent_ids.map { |id| [id] }
    end
  end

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

    map_results filter.depth_0_ids, filter.depth_1_ids
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