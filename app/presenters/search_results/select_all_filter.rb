module SearchResults

  class SelectAllFilter < Filter

    def initialize(filter, params)
      @filter   = filter
      @params   = params

      yield self if block_given?

      @depth_0_vals, @depth_1_vals = filter_by_all_selection_within_category
    end
    delegate  :group_prop_category_ids,
              :selected_property_ids,
              :selected_value_pairs,
              :selected_property_ids_by_depth, :to => :filter

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
      category_ids = params_for_all_to_category_ids

      if category_ids
        [filter_by_all_selection(Depth::PARENT), filter_by_all_selection(Depth::CHILD)]
      else
        [@filter.depth_0_vals, @filter.depth_1_vals]
      end
    end

    def filter_by_all_selection(depth)
      category_ids_at_depth = category_ids_at(depth)
      vals_at_depth         = @filter.vals_at(depth)

      if category_ids_at_depth.any?
        @filter_strategy_instance ||= strategy_class.new(self)
        @filter_strategy_instance.select_vals_by_all(vals_at_depth, category_ids_at_depth)
      else
        vals_at_depth
      end
    end

    def category_ids_at(depth)
      # group_prop_category_ids defined in CategorizedParamsAdapter
      group_prop_category_ids(depth).select { |c| params_for_all_to_category_ids.include?(c) }
    end

    def params_for_all_to_category_ids
      # {"1"=>"all", "2"=>"any"} --> [1]
      @params_for_all_to_category_ids ||= begin
        category_all_pairs = @params[grouping].group_by { |k,v| v }["all"] || []
        category_all_pairs.map { |c| c.first }.map(&:to_i)
      end
    end

  end

  class SelectAllStrategy
    attr_accessor :filter
    def initialize(filter)
      @filter = filter
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
      @filter.selected_property_ids(category_id)
    end

  end

  class SelectAllLingsPropertyStrategy < SelectAllStrategy

    def column
      :property_value
    end

    def selection_by_category_id(category_id)
      @filter.selected_value_pairs(category_id)
    end

  end

end