class Search

  attr_accessor :lings, :params
  attr_reader :lings, :properties

  def self.factory(params = {})
    show_param = params[:show] || {}
    show_ling = show_param[:ling]
    show_prop = show_param[:property]

    if show_param[:lings_property]
      LingsPropertySearch.new(params)
    elsif show_param[:ling]
      LingSearch.new(params)
    elsif show_param[:property]
      PropertySearch.new(params)
    else
      Search.new(params)
    end
  end

  def initialize(params = {})
    @params = params
  end

  def ling_options
    all_lings.map { |l| [l.name, l.id] }
  end

  def property_options
    all_properties.map { |p| [p.name, p.id] }
  end

  def results
    []
  end

  def show?(search_type)
    show_param[search_type].present?
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