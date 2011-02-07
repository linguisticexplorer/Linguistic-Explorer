class LingSearch < Search

  def results
    all_results = Ling.select("lings.name AS ling_name, lings.id AS ling_id")

    all_results = all_results.where("lings.id in (?)", params[:lings]) if params[:lings].present?

    if show? :property
      all_results = all_results.
        select("properties.name AS prop_name, properties.id AS prop_id").
        joins(:properties).
        where("lings_properties.property_id" => params[:properties]).
        includes(:properties)
    end

    all_results
  end
end