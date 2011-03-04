module SearchResults
  include Enumerable

  def each
    results.each { |r| yield r }
  end

  def results
    LingsProperty.with_id(selected_lings_prop_ids).includes([:ling, :property])
  end

  private

  def parent
    Ling::PARENT
  end

  def child
    Ling::CHILD
  end

  def selected_lings_prop_ids
    depth_0_vals  = filter_depth_0_lings_prop_ids
    depth_1_vals  = filter_depth_1_lings_prop_ids

    filtered_vals = intersect_lings_prop_ids(depth_0_vals, depth_1_vals)

    relation      = filter_by_lings_prop_params(filtered_vals)

    relation.map(&:id)
  end

  def filter_depth_0_lings_prop_ids
    LingsProperty.ids.ling_ids.where(:ling_id => queryable_ling_ids(parent), :property_id => queryable_prop_ids(parent))
  end

  def filter_depth_1_lings_prop_ids
    queryable_ling_ids(child).any? ? LingsProperty.ids.ling_ids.where(:ling_id => queryable_ling_ids(child), :property_id => queryable_prop_ids(child)) : []
  end

  def intersect_lings_prop_ids(depth_0_vals, depth_1_vals)
    if depth_1_vals.any?
      depth_1_vals  = ( LingsProperty.ids.with_id(depth_1_vals.map(&:id)) & Ling.parent_ids.with_parent_id(depth_0_vals.map(&:ling_id)))
      depth_0_vals  =   LingsProperty.ids.with_id(depth_0_vals.map(&:id)).with_ling_id(depth_1_vals.map(&:parent_id))
    end

    depth_0_vals + depth_1_vals
  end

  def all_lings_prop_ids
    @all_lings_prop_ids ||= LingsProperty.ids
  end

  def filter_by_lings_prop_params(filtered)
    lings_prop_params.any? ? LingsProperty.ids.where(lings_prop_param_conditions & {:id => filtered}) : filtered
  end

  def ling_params
    @params[:lings] || []
  end

  def prop_params
    @params[:properties] || []
  end

  def lings_prop_params
    @params[:lings_props] || []
  end

  def ling_params_to_hash
    ling_params.inject({}) { |memo, h| memo.merge(h) }
  end

  def prop_params_to_hash
    prop_params.inject({}) { |memo, h| memo.merge(h) }
  end

  def queryable_ling_ids(depth)
    ling_params_to_hash[depth.to_s] || all_group_ling_ids(depth)
  end

  def all_group_ling_ids(depth)
    Ling.select("lings.id").in_group(@group).at_depth(depth)
  end

  def queryable_prop_ids(depth)
    prop_param_ids_at_depth(depth).any? ? prop_param_ids_at_depth(depth) : all_group_prop_ids(depth)
  end

  def prop_param_ids_at_depth(depth)
    prop_params_to_hash.reject { |k,v| !group_prop_categories(depth).include?(k) }.values.flatten || []
  end

  def all_group_prop_ids(depth)
    Property.ids.in_group(@group).at_depth(depth)
  end

  def lings_prop_param_conditions
    conditions = lings_prop_param_pairs.inject({:id => nil}) do |conds, pair|
      conds | { :property_id => pair.first, :value => pair.last }
    end
  end

  def lings_prop_param_pairs
    lings_prop_params.map(&:values).flatten.map { |str| str.split(":") }
  end

  def group_prop_categories(depth)
    group_categories.select { |c| c.depth == depth }.map { |c| c.name.downcase }
  end

  def group_categories
    @group_categories ||= Category.in_group(@group)
  end
end