module SearchForm

  attr_accessor :lings, :properties, :lings_props, :property_set, :lings_property_set, :lings_keywords

  def ling_options(depth)
    group_lings_at_depth(depth).map { |l| [l.name, l.id] }
  end

  def property_options(category)
    group_properties_in_category(category).map { |p| [p.name, p.id] }
  end

  def lings_prop_options(category)
    group_lings_props_in_category(category).map { |p| ["#{p.prop_name}: #{p.value}", "#{p.property_id}:#{p.value}"] }
  end

  def ling_depths
    @ling_depths ||= Ling.select("DISTINCT depth").map(&:depth)
  end

  def property_categories
    @property_categories ||= Category.in_group(@group).order(:name)
  end

  def has_ling_children?
    group_lings_at_depth(Depth::CHILD).any?
  end

  protected

  def group_lings_at_depth(depth)
    group_lings.select { |l| l.depth.to_i == depth.to_i }
  end

  def group_properties_in_category(category)
    group_properties.select { |c| c.category_id.to_i == category.id }
  end

  def group_lings_props_in_category(category)
    group_lings_props.select { |pv| pv.category_id.to_i == category.id }
  end

  def group_lings
    @group_lings ||= Ling.in_group(@group).order(:name)
  end

  def group_properties
    @group_properties ||= Property.in_group(@group).order_by_name
  end

  def group_lings_props
    @group_lings_props ||= LingsProperty.in_group(@group).group(LingsProperty.group_by_statement).includes(:property) & Property.order_by_name
  end

  def show_param
    @show_param ||= @params[:show] || {}
  end

end