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
    
    if @params[:lings_properties].present?
      all_results = all_results.where("lings_properties.id" => selected_lings_prop_ids)
    end
    
    all_results
  end

  def selected_ling_ids
    @params[:lings] || Ling.select("id")
  end

  def selected_prop_ids
    @params[:properties] || Property.select("id")
  end

  def selected_lings_prop_ids
    pairs = @params[:lings_properties].map { |str| str.split(":") }
    props_ids = pairs.map(&:first)
    values    = pairs.map(&:last)
    LingsProperty.select("id").where(:property_id => props_ids, :value => values)
  end
end