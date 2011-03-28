module SearchResults

  class SelectAllFilter < Filter

    def initialize(filter, params)
      @filter   = filter
      @params   = params

      yield self if block_given?

      @depth_0_vals, @depth_1_vals = filter_by_all_selection_within_category
    end

    def grouping
      "#{@strategy}_set".to_sym
    end

    def strategy_class
      "SearchResults::SelectAll#{@strategy.to_s.camelize}Strategy".constantize
    end

    def strategy=(strategy)
      @strategy = strategy
    end

    def filter_by_all_selection_within_category
      [filter_by_all_selection(Depth::PARENT), filter_by_all_selection(Depth::CHILD)]
    end

    def filter_by_all_selection(depth)
      category_ids_at_depth = @params.category_ids_by_all_grouping_and_depth(grouping, depth)
      vals_at_depth         = @filter.vals_at(depth)

      if category_ids_at_depth.any?
        @filter_strategy_instance ||= strategy_class.new(@params)
        @filter_strategy_instance.select_vals_by_all(vals_at_depth, category_ids_at_depth)
      else
        vals_at_depth
      end
    end

  end

  class SelectAllStrategy
    attr_accessor :filter
    def initialize(params)
      @params = params
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
      vals.select do |v|
        associated.map(&:to_s).all? { |col|
          vals_with_ling_id_and_column(vals, v.ling_id).include?(col)
        }
      end
    end

    def vals_with_ling_id_and_column(vals, ling_id)
      vals_by_ling_id(vals)[ling_id].map(&column).map(&:to_s)
    end

    def vals_by_ling_id(vals)
      # [vals] --> {1 => [val,val], 2 ==> [val, val] etc.}
      vals.group_by { |v| v.ling_id }
    end

  end

  class SelectAllPropertyStrategy < SelectAllStrategy

    def column
      :property_id
    end

    def selection_by_category_id(category_id)
      @params.selected_property_ids(category_id)
    end

  end

  class SelectAllLingsPropertyStrategy < SelectAllStrategy

    def column
      :property_value
    end

    def selection_by_category_id(category_id)
      @params.selected_value_pairs(category_id)
    end

  end

end