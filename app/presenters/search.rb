class Search

  attr_accessor :lings
  attr_reader :lings, :properties

  def initialize(params)
    @params = params
  end

  def ling_options
    all_lings.map { |l| [l.name, l.id] }
  end

  def property_options
    all_properties.map { |p| [p.name, p.id] }
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
    Ling.all
  end

  def all_properties
    Property.all
  end

  def show_param
    @show_param ||= @params[:show] || {}
  end

end