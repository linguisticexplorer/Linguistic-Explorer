module SearchResults
  class SelectAllFilter
    attr_reader :depth_0_vals, :depth_1_vals

    def initialize(filter, adapter, prop_params, params)
      @filter   = filter
      @adapter  = adapter
      @prop_params = prop_params
      @params   = params

      @depth_0_vals, @depth_1_vals = perform_all_and_intersect
    end

    def perform_all_and_intersect
      category_ids = params_for_all_to_category_ids

      if category_ids
        @depth_0_vals = filter_by_all_selection(Depth::PARENT)
        @depth_1_vals = filter_by_all_selection(Depth::CHILD)
        @filter = IntersectionFilter.new(self, @prop_params)
      end

      [@filter.depth_0_vals, @filter.depth_1_vals]
    end

    def filter_by_all_selection(depth)
      category_ids_at_depth = @adapter.group_prop_category_ids(depth).select { |c| params_for_all_to_category_ids.include?(c) }
      vals = depth == Depth::PARENT ? @filter.depth_0_vals : @filter.depth_1_vals
      if category_ids_at_depth.any?
        prop_ids = Property.ids.where(:category_id => category_ids_at_depth, :id => @prop_params[depth])

        # select depth vals whose ling_ids have all properties in category for all section
        vals.ling_ids.group("lings_properties.property_id").having(:property_id => prop_ids)
      else
        vals
      end
    end

    def params_for_all_to_category_ids
      # {"1"=>"all", "2"=>"any"} --> [1]
      category_all_pairs = @params.group_by { |k,v| v }["all"] || []
      category_all_pairs.map { |c| c.first }.map(&:to_i)
    end

  end
  
end