module SearchResults

  class ResultAdapter

    attr_internal :result_groups

    def initialize(query, results)
      @query = query
      @results = results
    end

    def any?
      parent.any? || child.any?
    end

    def parent
      @results[Depth::PARENT] || []
    end

    def child
      @results[Depth::CHILD] || []
    end

    def result_groups
      @result_groups || []
    end

    def type
      return kind_of_implication if is_implication?
      return :cross if is_cross_search?
      return :compare if is_compare_search?
      :default
    end

    def columns
      @query.included_columns
    end

    def depth_for_cross
      @query.depth_of_cross_search
    end

    def depth_for_compare
      @query.depth_of_compare_search
    end

    def chosen_lings
      @query.selected_ling_ids_to_compare(depth_for_compare)
    end

    def depth_for_implication
      @query.depth_of_implication
    end

    private

    def is_cross_search?
      @query.is_cross_search?
    end

    def is_compare_search?
      @query.is_compare_search?
    end

    def is_implication?
      @query.is_implication_search?
    end

    def is_impl_both?
      @query.is_both_implication_search?
    end

    def is_impl_ante?
      @query.is_antecedent_implication_search?
    end

    def is_impl_cons?
      @query.is_consequent_implication_search?
    end

    def kind_of_implication
      return :implication_both if is_impl_both?
      return :implication_ante if is_impl_ante?
      return :implication_cons if is_impl_cons?
    end

  end

end