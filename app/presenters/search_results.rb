module SearchResults
  include Enumerable

  def each
    results.each { |r| yield r }
  end

  def results
    LingsProperty.where("lings_properties.id" => selected_lings_prop_ids).joins([:ling, :property])
  end

  private

  def selected_lings_prop_ids
    relation = LingsProperty.select("lings_properties.id")

    depth_0_vals  = relation.select("lings_properties.ling_id").
                      where(:ling_id => selected_ling_ids(0), :property_id => selected_prop_ids(0))

    depth_1_vals  = []

    if selected_ling_ids(1).any?
      depth_1_vals  = relation.select("lings_properties.ling_id").
                        where(:ling_id => selected_ling_ids(1), :property_id => selected_prop_ids(1))

      # intersection
      depth_1_vals  = relation.select("lings_properties.ling_id, lings.parent_id").
                        joins(:ling).
                        where("lings_properties.id" => depth_1_vals.map(&:id),
                          "lings.parent_id" => depth_0_vals.map(&:ling_id))

      depth_0_vals  = relation.where("lings_properties.id" => depth_0_vals.map(&:id),
                        "lings_properties.ling_id" => depth_1_vals.map(&:parent_id))
    end

    filtered = depth_0_vals + depth_1_vals

    relation = if prop_val_params.any?
                  relation.where(prop_val_params_conditions & {:id => filtered})
                else
                  filtered
                end

    relation.map(&:id)
  end

  def ling_params
    @params[:lings] || []
  end

  def prop_params
    @params[:properties] || []
  end

  def prop_val_params
    @params[:prop_vals] || []
  end

  def ling_params_to_hash
    ling_params.inject({}) { |memo, h| memo.merge(h) }
  end

  def prop_params_to_hash
    prop_params.inject({}) { |memo, h| memo.merge(h) }
  end

  def selected_ling_ids(depth)
    param_ids = ling_params_to_hash[depth.to_s]
    param_ids || Ling.select("lings.id").in_group(@group).at_depth(depth.to_i)
  end

  def selected_prop_ids(depth)
    param_ids = prop_params_to_hash.reject { |k,v| !group_prop_categories(depth).include?(k) }.values.flatten
    param_ids && param_ids.any? ? param_ids : Property.select("properties.id").in_group(@group).at_depth(depth.to_i)
  end

  def prop_val_params_conditions
    pairs = prop_val_params.map(&:values).flatten.map { |str| str.split(":") }
    conditions = pairs.inject({:id => nil}) do |conds, pair|
      conds | { :property_id => pair.first, :value => pair.last }
    end
  end

  def group_prop_categories(depth)
    group_categories.select { |c| c.depth == depth }.map { |c| c.name.downcase }
  end

  def group_categories
    @group_categories ||= Category.scoped.in_group(@group)
  end
end