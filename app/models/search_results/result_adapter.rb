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
      :default
    end

    def columns
      @query.included_columns
    end

    def depth_for_cross
      @query.depth_of_cross_search
    end

    private

    def is_cross_search?
      @query.is_cross_search?
    end

    def assert_is_valid_cross
      # TODO: write something nicer here
      properties = @query.selected_properties_to_cross(depth_for_cross)
      # Raise an Exception if there are less properties than required
      raise Exceptions::ResultAtLeastTwoForCrossError if properties.size < 2
      # Avoid Cartesian Product with too many properties
      raise Exceptions::ResultTooManyForCrossError if properties.size > Search::RESULTS_CROSS_THRESHOLD
    end

  end

end