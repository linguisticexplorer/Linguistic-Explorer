module SearchesHelper
  # Search form
  def search_field_name(method, scope)
    "search[#{method.to_s}][][#{scope.to_s.underscorize}][]"
  end
  
  def search_options_label(text)
    "#{text.underscorize}_options"
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