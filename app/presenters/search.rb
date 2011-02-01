class Search

  attr_accessor :ling_included, :lings, :params
  attr_reader :lings, :properties

  def initialize(params = {})
    @params = params
  end

  def ling_options
    all_lings.map { |l| [l.name, l.id] }
  end

  def property_options
    all_properties.map { |p| [p.name, p.id] }
  end

  def lings
    @lings ||= Ling.find(params[:lings]||[])
  end

  def properties
    @properties ||= Property.find(params[:properties]||[])
  end

  def lings_properties
    LingsProperty.all(:conditions => {
      :property_id => params[:properties], :ling_id => params[:lings] },
      :include => [:property, :ling])
  end

  def include_properties?
    include? :property
  end

  def include_lings?
    include? :ling
  end

  def include?(search_type)
    include_param[search_type].present?
  end

  protected

  def all_lings
    Ling.all
  end

  def all_properties
    Property.all
  end

  def include_param
    @include_param ||= @params[:include] || {}
  end

end