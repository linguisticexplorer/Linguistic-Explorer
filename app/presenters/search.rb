class Search

  attr_accessor :lings, :properties, :prop_vals

  def initialize(group, params)
    @group  = group
    @params = params
  end

  def ling_options
    group_lings.map { |l| [l.name, l.id] }
  end

  def property_options
    group_properties.map { |p| [p.name, p.id] }
  end

  def lings_property_options(category = nil)
    prop_vals = group_prop_vals
    prop_vals = prop_vals.select { |pv| pv.category == category } unless category.nil?
    prop_vals.map { |p| ["#{p.name}: #{p.value}", "#{p.property_id}:#{p.value}"] }
  end

  def prop_categories
    @prop_categories ||= begin
      group_prop_categories.each do |category|
        self.class.send(:attr_accessor, "#{category.underscorize}_prop_vals")
      end
    end
  end

  def show?(search_type)
    # TODO Not checking "Incude" option to show yet
    # show_param[search_type].present?
    true
  end

  def results
    @results ||= SearchResultSet.new(@params)
  end

  protected

  def group_lings
    Ling.select("id, name").where(:group => @group)
  end

  def group_properties
    Property.select("id, name, category").where(:group => @group)
  end

  def group_prop_vals(category = nil)
    @group_prop_vals ||= LingsProperty.select("properties.name, properties.category, lings_properties.value, properties.id AS property_id").
      where(:group => @group).
      joins(:property).
      group("properties.id, lings_properties.value")
  end

  def group_prop_categories
    @group_prop_categories ||= Property.select("category").where(:group => @group).group("category").map(&:category)
  end

  def show_param
    @show_param ||= @params[:show] || {}
  end

end