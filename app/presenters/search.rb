class Search
  include Searching

  attr_accessor :lings, :properties, :prop_vals

  def initialize(group, params)
    @group  = group
    @params = params
  end

  def ling_options(depth = nil)
    collection = group_lings
    collection = collection.where(:depth => depth) unless depth.nil?
    collection.map { |l| [l.name, l.id] }
  end

  def property_options(category = nil)
    collection = group_properties
    collection = collection.select { |c| c.category == category } unless category.nil?
    collection.map { |p| [p.name, p.id] }
  end

  def prop_val_options(category = nil)
    collection = group_prop_vals
    collection = collection.select { |pv| pv.category == category } unless category.nil?
    collection.map { |p| ["#{p.name}: #{p.value}", "#{p.property_id}:#{p.value}"] }
  end

  def ling_depths
    @ling_depths ||= group_lings.group(:depth).map(&:depth)
  end

  def prop_categories
    @prop_categories ||= group_properties.map(&:category).uniq
  end

  def show?(search_type)
    # TODO Not checking "Include" option to show yet
    # show_param[search_type].present?
    true
  end

  def has_ling_depth?
    group_lings.where(:depth => 1).any?
  end

  protected

  def group_lings
    @group_lings ||= Ling.where(:group => @group)
  end

  def group_properties
    @group_properties ||= Property.where(:group => @group)
  end

  def group_prop_vals(category = nil)
    @group_prop_vals ||= LingsProperty.select("properties.name, properties.category, lings_properties.value, properties.id AS property_id").
      where(:group => @group).
      joins(:property).
      group("properties.id, lings_properties.value")
  end

  def show_param
    @show_param ||= @params[:show] || {}
  end

end