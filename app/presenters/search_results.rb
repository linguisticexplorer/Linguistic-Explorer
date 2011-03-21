module SearchResults
  include Enumerable

  def each
    results.each { |r| yield r }
  end

  def results
    LingsProperty.with_id(selected_lings_prop_ids).includes([{:ling => :parent}, :property])
  end

  private

  def parent
    Depth::PARENT
  end

  def child
    Depth::CHILD
  end

  def selected_lings_prop_ids
    # Filters return depth_0_vals and depth_1_vals

    filter = filter_by_ling_and_prop_params

    filter = filter_by_lings_prop_params filter

    filter = intersect_lings_prop_ids filter

    filter = filter_by_all_conditions(filter, :property_set)

    # filter = filter_by_all_conditions(filter, :lings_property_set)

    filter = intersect_lings_prop_ids filter

    (filter.depth_0_vals + filter.depth_1_vals).map(&:id)
  end

  def filter_by_ling_and_prop_params
    params_filter
  end

  def params_filter
    @params_filter ||= LingsPropsParamsFilter.new(@group,
      :lings => @params[:lings],
      :properties => convert_to_depth_params(@params[:properties]))
  end
  delegate  :prop_params,
            :to => :params_filter

  def category_adapter
    @category_adapter ||= CategorizedParamsAdapter.new(@group)
  end
  delegate  :group_prop_category_ids,
            :category_present?,
            :convert_to_depth_params,   :to => :category_adapter


  def filter_by_lings_prop_params(filter)
    ValuePairParamsFilter.new(filter, category_adapter, @params[:lings_props] || {})
  end

  def intersect_lings_prop_ids(filter)
    IntersectionFilter.new(filter, prop_params)
  end

  def filter_by_all_conditions(filter, grouping)
    SelectAllFilter.new(filter, category_adapter, prop_params, @params[grouping])
  end

end