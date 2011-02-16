class Search

  attr_accessor :lings, :properties, :lings_properties

  def initialize(params)
    @params = params
  end

  def ling_options
    all_lings.map { |l| [l.name, l.id] }
  end

  def property_options
    all_properties.map { |p| [p.name, p.id] }
  end

  def lings_property_options
    all_lings_properties.map { |p| ["#{p.name}: #{p.value}", "#{p.property_id}:#{p.value}"] }
  end

  def results
    SearchResultSet.new(@params)
  end

  def show?(search_type)
    # TODO Not checking "Incude" option to show yet
    # show_param[search_type].present?
    true
  end

  protected

  def all_lings
    Ling.select("id, name")
  end

  def all_properties
    Property.select("id, name")
  end

  def all_lings_properties
    LingsProperty.select("properties.name, lings_properties.value, properties.id AS property_id").
      joins(:property).
      group("properties.id, lings_properties.value")
  end

  def show_param
    @show_param ||= @params[:show] || {}
  end

end