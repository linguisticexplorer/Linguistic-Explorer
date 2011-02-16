module SearchesHelper

  def search_result_attributes(result)
    {}.tap do |attrs|
      attrs[:class] = "row #{dom_class(result, :result)}"
      attrs["data-ling"] = result.ling_id
      attrs["data-prop"] = result.prop_id
    end
  end
end