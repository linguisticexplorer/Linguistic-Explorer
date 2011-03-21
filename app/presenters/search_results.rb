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
    depth_0_vals, depth_1_vals = filter_by_ling_and_prop_params

    depth_0_vals, depth_1_vals = filter_by_lings_prop_params

    depth_0_vals, depth_1_vals = intersect_lings_prop_ids value_pair_params_filter, depth_0_vals, depth_1_vals

    depth_0_vals, depth_1_vals = filter_by_all_conditions(depth_0_vals, depth_1_vals, :property_group)

    depth_0_vals, depth_1_vals = filter_by_all_conditions(depth_0_vals, depth_1_vals, :lings_property_group)

    (depth_0_vals + depth_1_vals).map(&:id)
  end

  def filter_by_ling_and_prop_params
    [params_filter.depth_0_vals, params_filter.depth_1_vals]
  end

  def filter_by_lings_prop_params
    [value_pair_params_filter.depth_0_vals, value_pair_params_filter.depth_1_vals]
  end

  def params_filter
    @params_filter ||= LingsPropsParamsFilter.new(@group,
      :lings => @params[:lings],
      :properties => convert_to_depth_params(@params[:properties]))
  end
  delegate  :depth_0_prop_ids,
            :depth_1_prop_ids,
            :to => :params_filter

  def category_adapter
    @category_adapter ||= CategorizedParamsAdapter.new(@group)
  end
  delegate  :group_prop_category_ids,
            :category_present?,
            :convert_to_depth_params,   :to => :category_adapter

  def value_pair_params_filter
    @value_pair_params_filter ||= ValuePairParamsFilter.new(params_filter, category_adapter, @params[:lings_props] || {})
  end

  def intersect_lings_prop_ids(filter)
    intersection_filter = IntersectionFilter.new(filter, depth_0_prop_ids, depth_1_prop_ids)
    [intersection_filter.depth_0_vals, intersection_filter.depth_1_vals]
  end

  def filter_by_all_conditions(depth_0_vals, depth_1_vals, grouping)
    all_selection = @params[grouping].group_by { |k,v| v }["all"]
    if all_selection
      cats = all_selection.map { |c| c.first }.map(&:to_i) # get category ids to group by all
      parent_cats = group_prop_category_ids(parent).select { |c| cats.include?(c) }
      child_cats = group_prop_category_ids(child).select { |c| cats.include?(c) }
      if parent_cats.any?
        parent_prop_ids = Property.ids.where(:category_id => parent_cats, :id => depth_0_prop_ids)
        depth_0_vals    = depth_0_vals.ling_ids.group("lings_properties.property_id").having(:property_id => parent_prop_ids)
      end
      if child_cats.any?
        child_prop_ids  = Property.ids.where(:category_id => child_cats, :id => depth_1_prop_ids)
        depth_1_vals    = depth_1_vals.ling_ids.group(:property_id).having(:property_id => child_prop_ids)
      end

      intersect_lings_prop_ids(DummyFilter.new(depth_0_vals, depth_1_vals))
    else
      [depth_0_vals, depth_1_vals]
    end
  end

  class DummyFilter
    attr_reader :depth_0_vals, :depth_1_vals
    def initialize(depth_0_vals, depth_1_vals)
      @depth_0_vals, @depth_1_vals = depth_0_vals, depth_1_vals
    end
  end

end