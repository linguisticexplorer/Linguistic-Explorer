class SearchResultSet
  include Enumerable

  def initialize(params)
    @params = params
  end

  def each
    results.each { |r| yield r }
  end

  def results
    all_results = select_lings.joins(:properties) & select_properties

    if @params[:lings_properties].present?
      all_results = all_results & select_lings_properties
    end
    
    all_results
  end
  
  private
  
  def select_lings
    Ling.select("lings.name AS ling_name, lings.id AS ling_id").where("lings.id in (?)", selected_ling_ids)
  end
  
  def select_properties
    Property.select("properties.name AS prop_name, properties.id AS prop_id").where("properties.id in (?)", selected_prop_ids)
  end
  
  def select_lings_properties
    LingsProperty.where("lings_properties.id" => selected_lings_prop_ids)
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