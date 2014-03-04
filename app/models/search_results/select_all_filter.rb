module SearchResults

  class SelectAllFilter < Filter
    attr_accessor :strategy

    def initialize(filter, query)
      #@filter   = filter
      #@query   = query
      super
      yield self if block_given?

      @depth_0_vals, @depth_1_vals = filter_by_all_selection_within_category

      @depth_0_vals, @depth_1_vals = perform_intersection_of_results if intersection_required?
    end

    def strategy
      @strategy ||= :property
    end

    private

    def grouping
      "#{@strategy}_set".to_sym
    end

    def filter_by_all_selection_within_category
      [filter_by_all_selection(Depth::PARENT), filter_by_all_selection(Depth::CHILD)]
    end

    def filter_by_all_selection(depth)
      category_ids_at_depth = @query.category_ids_by_all_grouping_and_depth(grouping, depth)
      vals_at_depth         = @filter.vals_at(depth)

      if category_ids_at_depth.any?
        @intersection_required = true
        @filter_strategy_instance ||= strategy_class.new(@query)
        @filter_strategy_instance.select_vals_by_all(vals_at_depth, category_ids_at_depth)
      else
        vals_at_depth
      end
    end

    def strategy_class
      "SearchResults::SelectAll#{@strategy.to_s.camelize}Strategy".constantize
    end

    private

    def perform_intersection_of_results
      intersection_filter = IntersectionFilter.new(self, @query)
      [intersection_filter.depth_0_vals, intersection_filter.depth_1_vals]
    end

    def intersection_required?
      @intersection_required
    end
  end

  class SelectAllStrategy
    attr_accessor :filter
    def initialize(query)
      @query = query
    end

    def select_vals_by_all(vals, category_ids)
      category_ids.collect do |category_id|
        required = selection_by_category_id(category_id)
        next if required.empty?
        collect_all_from_vals(vals, required)
      end.flatten.compact
    end

    def collect_all_from_vals(vals, associated)
      # select depth vals whose ling_ids have all column value in category for all section
      result = vals.select do |v|
        associated.map(&:to_s).all? { |col|
          vals_with_ling_id_and_column(vals, v.ling_id).include?(col)
        }
      end

      return result
    end

    def vals_with_ling_id_and_column(vals, ling_id)
      result = vals_by_ling_id(vals)[ling_id].map(&column).map(&:to_s)

      return result
    end

    def vals_by_ling_id(vals)
      # [vals] --> {1 => [val,val], 2 ==> [val, val] etc.}
      result = vals.group_by { |v| v.ling_id }
      
      return result
    end

  end

  class SelectAllPropertyStrategy < SelectAllStrategy

    def column
      :property_id
    end

    def selection_by_category_id(category_id)
      @query.selected_property_ids(category_id)
    end

  end

  class SelectAllLingsPropertyStrategy < SelectAllStrategy

    def column
      :property_value
    end

    def selection_by_category_id(category_id)
      @query.selected_value_pairs(category_id)
    end

  end

end