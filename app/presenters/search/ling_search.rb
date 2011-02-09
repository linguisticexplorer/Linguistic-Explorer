class LingSearch < Search

  def results
    if show? :ling
    all_results = Ling.select("lings.name AS ling_name, lings.id AS ling_id").
      where("lings.id in (?)", selected_ling_ids)
    end

    if show? :property
      all_results = all_results.
        select("properties.name AS prop_name, properties.id AS prop_id").
        joins(:properties).
        where("lings_properties.property_id" => selected_prop_ids)
    end

    all_results
  end

  def selected_ling_ids
    params[:lings] || Ling.select("id")
  end

  def selected_prop_ids
    params[:properties] || Property.select("id")
  end

end