module SearchForm

  attr_accessor :lings,         :properties,          :lings_props,
                :property_set,  :lings_property_set,
                :ling_keywords, :property_keywords,   :example_keywords,
                :example_fields

  def ling_options(depth)
    group_lings_at_depth(depth).map { |l| [l.name, l.id] }
  end

  def property_options(category)
    group_properties_in_category(category).map { |p| [p.name, p.id] }
  end

  def lings_prop_options(category)
    results = group_lings_props_in_category(category).map { |lp|
        ["#{lp.prop_name}: #{lp.value}", lp.property_value] }
  end

  def example_field_options
    @group.example_storable_keys.map { |ef| ["#{ef.titleize} Contains", ef.downcase ] }
  end

  def property_categories
    @property_categories ||= Category.in_group(@group).order(:depth, :name)
  end

  def has_ling_children?
    group_lings_at_depth(Depth::CHILD).any?
  end

  protected

  def group_lings_at_depth(depth)
    results = group_lings(depth)
  end

  def group_properties_in_category(category)
    results = group_properties(category)
  end

  def group_lings_props_in_category(category)
    group_lings_props(category)
  end

  def group_lings(depth)
    @group_lings = Ling.in_group(@group).order(:name).where(:depth => depth.to_i)
  end

  def group_properties(category)
    @group_properties = Property.in_group(@group).order_by_name.where(:category => category)
  end

  def group_lings_props(category)
    select_string = "properties.`id`, lings_properties.`id`, lings_properties.`ling_id`, lings_properties.`property_id`, lings_properties.`property_value`, lings_properties.`value`, count(*)"
    group_string = "properties.`name`, lings_properties.`value`, lings_properties.`property_value`"
    order_string = "properties.`name`"
    where_string = "properties.`category_id`= ?"
    @group_lings_props = LingsProperty.
          in_group(@group).
          select(select_string).
          joins(:property).
          group(group_string).
          order(order_string).
          where(where_string, category.id).
          includes(:property)
  end

end