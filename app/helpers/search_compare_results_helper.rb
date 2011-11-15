module SearchCompareResultsHelper

  def results_in_common_compare_search(results)
    results.select {|result| result.child.size==1 }
  end

  def results_diff_compare_search(results)
    results.select {|result| result.child.size>1 }
  end
end