module SearchResults
  include Enumerable

  def each
    results.each { |r| yield r }
  end

  def results
    # select_lings & select_properties & select_lings_properties
    LingsProperty.where("lings_properties.id" => selected_lings_prop_ids).includes([:ling,:property])
  end

  private

  def select_lings
    # Ling.select("lings.name AS ling_name, lings.id AS ling_id").where("lings.id in (?)", selected_ling_ids)
    Ling.select("lings.name AS ling_name, lings.id AS ling_id")
  end

  def select_properties
    # Property.select("properties.name AS prop_name, properties.id AS prop_id").where("properties.id in (?)", selected_prop_ids)
    Property.select("properties.name AS prop_name, properties.id AS prop_id")
  end

  def select_lings_properties
    LingsProperty.select("lings_properties.value AS value").where("lings_properties.id" => selected_lings_prop_ids)
  end

  def selected_lings_prop_ids
    relation = LingsProperty.select("lings_properties.id")

    depth_0_prop_ids  = selected_prop_ids(0)
    depth_1_prop_ids  = selected_prop_ids(1)

    # collect ling prop vals for depth 0
      # where in selected ling ids for depth 0
      # where in selected prop ids for depth 0
    depth_0_vals      = relation.select("lings_properties.ling_id").where(:ling_id => selected_ling_ids(0), :property_id => depth_0_prop_ids)

    # collect ling prop vals for depth 1
      # where in selected ling ids for depth 1
      # where in selected prop ids for depth 1
    depth_1_vals = []
    if selected_ling_ids(1).any?
      depth_1_vals      = relation.select("lings_properties.ling_id").where(:ling_id => selected_ling_ids(1), :property_id => depth_1_prop_ids)
      parent_ids        = Ling.where(:id => depth_1_vals.map(&:ling_id)).map(&:parent_id)

      depth_1_vals      = relation.joins(:ling).where("lings_properties.id" => depth_1_vals.map(&:id), "lings.parent_id" => depth_0_vals.map(&:ling_id))
      depth_0_vals      = relation.where("lings_properties.id" => depth_0_vals.map(&:id)).where("lings_properties.ling_id" => parent_ids)
    end

    filtered = [].tap do |val_ids|
      val_ids.concat depth_0_vals
      val_ids.concat depth_1_vals
    end

    if prop_val_params.present?
      # Reduce prop val params to one set of value pairs (ignoring category for now)
      pairs = prop_val_params.map(&:values).flatten.map { |str| str.split(":") }
      conditions = pairs.inject({:id => nil}) do |conds, pair|
        conds | { :property_id => pair.first, :value => pair.last }
      end
      relation = relation.where(conditions)
      relation = relation.where(:id => filtered) if filtered.any?
    else
      relation = filtered
    end

    relation.map(&:id)
  end

  def ling_params
    @params[:lings]
  end

  def ling_params_to_hash
    ling_params.inject({}) { |memo, h| memo.merge(h) }
  end

  def prop_params_to_hash
    prop_params.present? ? prop_params.inject({}) { |memo, h| memo.merge(h) } : {}
  end

  def selected_ling_ids(depth)
    param_ids = ling_params && ling_params_to_hash[depth.to_s]
    param_ids || Ling.select("lings.id").in_group(@group).at_depth(depth.to_i)
  end

  def prop_params
    @params[:properties]
  end

  def selected_prop_ids(depth)
    param_ids = prop_params_to_hash.reject { |k,v| !group_prop_categories(depth).include?(k) }.values.flatten
    param_ids && param_ids.any? ? param_ids : Property.select("properties.id").in_group(@group).at_depth(depth.to_i)
  end

  def prop_val_params
    @params[:prop_vals]
  end

  def group_prop_categories(depth)
    Category.scoped.in_group(@group).at_depth(depth).map { |c| c.name.downcase }
  end
end