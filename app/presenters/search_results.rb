module SearchResults
  include Enumerable
  include Layout

  def each
    results.each { |r| yield r }
  end

  def results
    LingsProperty.with_id(selected_lings_prop_ids).includes([{:ling => :parent}, :property])
  end

  private

  def selected_lings_prop_ids
    # Filters return depth_0_vals and depth_1_vals

    filter = filter_by_any_selected_lings_and_props

    filter = filter_by_keywords           filter, :ling

    filter = filter_by_keywords           filter, :property

    filter = filter_by_val_params         filter

    filter = filter_by_depth_intersection filter

    filter = filter_by_all_conditions     filter, :property

    filter = filter_by_all_conditions     filter, :lings_property

    filter = filter_by_depth_intersection filter

    (filter.depth_0_vals + filter.depth_1_vals).map(&:id)
  end

  def params
    @params_adapter ||= ParamsAdapter.new(@group, @params)
  end

  def filter_by_any_selected_lings_and_props
    SelectAnyFilter.new(params)
  end

  def filter_by_keywords(filter, strategy)
    KeywordFilter.new(filter, params) do |f|
      f.strategy = strategy
    end
  end

  def filter_by_val_params(filter)
    SelectValuePairsFilter.new(filter, params)
  end

  def filter_by_depth_intersection(filter)
    IntersectionFilter.new(filter, params)
  end

  def filter_by_all_conditions(filter, strategy)
    SelectAllFilter.new(filter, params) do |f|
      f.strategy = strategy
    end
  end

end