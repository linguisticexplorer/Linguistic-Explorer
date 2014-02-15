module SearchCrossResultsHelper

  def link_to_cross_lings(lings)
    return lings.count if lings.empty?
    link_to lings.count, :action => "lings_in_selected_row", :search => @search.query, :cross_ids => lings.map(&:id)
  end

  def search_result_attributes_for_cross(entry)
    {}.tap do |attrs|
      attrs[:class] = "search_result"
      # attrs["data-parent-value"] = entry.parent.inject("p") {|memo, lp| "#{memo}-#{lp.prop_name.hash - lp.property_value.hash}" }
      attrs["data-parent-value"] = entry.parent.map { |lp| "#{lp.ling_id}:#{lp.prop_id}:#{lp.property_value}"}.join("_")
      attrs["data-child-value"]  = "#{entry.child.count}-#{attrs["data-parent-value"]}"
    end
  end

  def search_result_attributes_for_ling_cross(entry)
    {}.tap do |attrs|
      attrs[:class] = "search_ling_result"
      attrs["data-parent-value"] = entry.id
    end
  end

end
