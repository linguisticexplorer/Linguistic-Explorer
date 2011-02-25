module SearchResults
  include Enumerable

  def each
    results.each { |r| yield r }
  end

  def results
    select_lings & select_properties & select_lings_properties
  end

  private

  def select_lings
    Ling.select("lings.name AS ling_name, lings.id AS ling_id").where("lings.id in (?)", selected_ling_ids)
  end

  def select_properties
    Property.select("properties.name AS prop_name, properties.id AS prop_id").where("properties.id in (?)", selected_prop_ids)
  end

  def select_lings_properties
    LingsProperty.select("lings_properties.value AS value").where("lings_properties.id" => selected_lings_prop_ids)
  end

  def selected_ling_ids
    ling_params_to_id || Ling.select("id").where(:group => @group)
  end

  def selected_prop_ids
    prop_params_to_id || Property.select("id").where(:group => @group)
  end

  def selected_lings_prop_ids
    relation = LingsProperty.select("id")

    filtered = relation.where(:ling_id => selected_ling_ids)
    filtered = filtered.where(:property_id => selected_prop_ids)

    if prop_val_params.present?
      # Reduce prop val params to one set of value pairs (ignoring category for now)
      pairs = prop_val_params.map(&:values).flatten.map { |str| str.split(":") }
      conditions = pairs.inject({:id => nil}) do |conds, pair|
        conds | { :property_id => pair.first, :value => pair.last }
      end
      relation = relation.where(conditions).where(:id => filtered)
    else
      relation = filtered
    end

    relation
  end

  def ling_params
    @params[:lings]
  end

  def ling_params_to_hash
    ling_params.inject({}) { |memo, h| memo.merge(h) }
  end

  def ling_params_to_id
    @ling_params_to_id ||= ling_params && ling_params.map(&:values).flatten
  end

  def prop_params
    @params[:properties]
  end

  def prop_params_to_id
    prop_params && prop_params.map(&:values).flatten
  end

  def prop_val_params
    @params[:prop_vals]
  end

end