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

  def lings_properties
    LingsProperty.all(:conditions => { :property_id => params[:properties], :ling_id => params[:lings] }, :include => [:property, :ling])
  end

  def include_properties?
    include? && @params[:include][:property].present?
  end

  def include?
    @params[:include].present?
  end

  protected

  def all_lings
    Ling.all
  end

  def all_properties
    Property.all
  end

end