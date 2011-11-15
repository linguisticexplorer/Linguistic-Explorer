module SearchCrossResultsHelper

  def link_to_cross_lings(parent, lings)
    return lings.count if lings.empty?
    link_to lings.count, :action => "cross_lings", :search => @search.query, :cross_ids => parent.map(&:id)
  end

  def search_result_attributes_for_cross(entry)
    {}.tap do |attrs|
      attrs[:class] = "search_result row"
      attrs["data-parent-value"] = entry.parent.inject(0) {|sum, lp| sum + lp.id}
      attrs["data-child-value"] = "#{attrs["data-parent-value"]}-#{entry.child.count}"
    end
  end

  def search_result_attributes_for_ling_cross(entry)
    {}.tap do |attrs|
      attrs[:class] = "search_ling_result row"
      attrs["data-parent-value"] = entry.id
    end
  end

end