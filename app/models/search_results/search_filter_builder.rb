module SearchResults

  class SearchFilterBuilder
    attr_accessor :filter
    attr_reader :query

    def initialize(query)
      @query = query
    end

    def perform_search
      ResultAdapter.new(@query, filtered_parent_and_child_ids)
    end

    private

    def filtered_parent_and_child_ids
      @filtered_parent_and_child_ids ||= filter_search_query
    end

    def filter_search_query
      # Filters return depth_0_vals and depth_1_vals

      @filter = filter_by_any_selected_lings_and_props

      @filter = filter_by_keywords           :ling

      @filter = filter_by_keywords           :property

      @filter = filter_by_keywords           :example

      @filter = filter_by_val_query_params

      @filter = filter_by_depth_intersection

      @filter = filter_by_all_conditions     :property

      @filter = filter_by_all_conditions     :lings_property

      #@filter = filter_by_cross_conditions

      [@filter.depth_0_ids, @filter.depth_1_ids]
    end

    def filter_by_cross_conditions
       CrossFilter.new(@filter, @query)
    end

    def filter_by_any_selected_lings_and_props
      SelectAnyFilter.new(@query)
    end

    def filter_by_keywords(strategy)
      KeywordFilter.new(@filter, @query) do |f|
        f.strategy = strategy
      end
    end

    def filter_by_val_query_params
      SelectValuePairsFilter.new(@filter, @query)
    end

    def filter_by_depth_intersection
      IntersectionFilter.new(@filter, @query)
    end

    def filter_by_all_conditions(strategy)
      SelectAllFilter.new(@filter, @query) do |f|
        f.strategy = strategy
      end
    end

  end

end