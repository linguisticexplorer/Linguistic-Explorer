class SearchResultSet
  include Enumerable

  def initialize(params)
    @params = params
  end

  def each
    results.each { |r| yield r }
  end

  def results
    all_results = Ling.select("lings.name AS ling_name, lings.id AS ling_id").
      where("lings.id in (?)", selected_ling_ids)

    all_results = all_results.
      select("properties.name AS prop_name, properties.id AS prop_id").
      joins(:properties).
      where("lings_properties.property_id" => selected_prop_ids)

    all_results
  end

  def selected_ling_ids
    @params[:lings] || Ling.select("id")
  end

  def selected_prop_ids
    @params[:properties] || Property.select("id")
  end

  def selected_lings_prop_ids
    @params[:lings_properties] || LingsProperty.select("id")
  end
end