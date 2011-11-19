module SearchCompareResultsHelper

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
    child ? row_methods[:ling_value].call(child) : ""
  end

  def value_for_header(results)
    result = results.first
    return result.child if result.common?
    result.lings
  end

  private

  def attributes_for_common_compare(entry)
    {}.tap do |attrs|
      attrs[:class] = "search_common_result row"
      attrs["data-common-parent-value"] = entry.parent.first.id
      attrs["data-common-child-value"] = entry.child.first.id
    end
  end

  def attributes_for_diff_compare(entry)
    {}.tap do |attrs|
      attrs[:class] = "search_diff_result row"
      attrs["data-diff-parent-value"] = entry.parent.first.id
      attrs["data-diff-child-value"] = entry.child.compact.inject(0) {|sum, lp| sum + lp.id}
    end
  end
end