module SearchesHelper
  # Search form
  def search_ling_label(search, depth)
    if search.has_ling_children?
      "#{current_group.ling_name_for_depth(depth).pluralize}".titleize
    else
      current_group.ling0_name
    end
  end

  def search_prop_label(category)
    "#{category.name} #{current_group.property_name.pluralize }".titleize
  end

  def search_text_id(text)
    "#{text.underscorize}_text"
  end

  def search_options_id(text)
    "#{text.underscorize}_options"
  end

  def search_text_field_name(method, scope)
    "search[#{method.to_s}][#{scope.to_s.underscorize}]"
  end

  def search_field_name(method, scope)
    "search[#{method.to_s}][#{scope.to_s.underscorize}][]"
  end

  def search_options_id(text)
    "#{text.underscorize}_options"
  end

  def categorized_field_name(method, scope)
    "search[#{method}_set][#{scope}]"
  end

  def categorized_set_id(name, type)
    "search_group_#{name.underscorize}_#{type}"
  end

  # Results

  def search_result_attributes(result)
    {}.tap do |attrs|
      attrs[:class] = "row #{dom_class(result, :result)}"
      attrs["data-ling"] = result.ling_id
      attrs["data-prop"] = result.prop_id
    end
  end
end