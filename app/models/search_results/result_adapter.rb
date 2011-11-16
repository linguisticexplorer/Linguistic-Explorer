module SearchResults

  class ResultAdapter

    attr_internal :result_groups

    def initialize(query, results)
      @query = query
      @results = results

      assert_is_valid_cross if is_cross_search?
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

    private

    def is_cross_search?
      @query.is_cross_search?
    end

    def is_compare_search?
      @query.is_compare_search?
    end

  end

end