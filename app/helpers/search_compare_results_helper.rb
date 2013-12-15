module SearchCompareResultsHelper

  def table_heading(text)
    content_tag(:h3,  text )
  end

  def results_in_common_compare_search(results)
    results.select {|result| result.common? }
  end

  def results_diff_compare_search(results)
    results.select {|result| !result.common? }
  end

  def search_result_attributes_for_compare(entry)
    return attributes_for_common_compare(entry) unless entry.child.size > 1
    attributes_for_diff_compare(entry)
  end

  def compare_diff_value(child)
    child.present? ? row_methods[:ling_value].call(child) : ""
  end

  def value_for_header(results)
    result = results.first
    return result.child if result.common?
    result.lings
  end

  def get_lings(results)
    results.first.lings.map(&:name).join(" , ")
  end

  def sort_by_ling(children, lings)
    [].tap do |sorted|
      lings.each { |ling| sorted << find_child_by_ling(children, ling) }
    end
  end

  private

  def attributes_for_common_compare(entry)
    {}.tap do |attrs|
      attrs[:class] = "search_common_result"
      attrs["data-common-parent-value"] = entry.parent.first.id
      attrs["data-common-child-value"] = entry.child.first.id
    end
  end

  def attributes_for_diff_compare(entry)
    {}.tap do |attrs|
      attrs[:class] = "search_diff_result"
      attrs["data-diff-parent-value"] = entry.parent.first.id
      attrs["data-diff-child-value"] = entry.child.compact.inject(0) {|sum, lp| sum + lp.id}
    end
  end

  def find_child_by_ling(children, ling)
    children.each do |c|
      next if c.nil?
      return c if c.ling_id == ling.id
    end
    return nil
  end
end
