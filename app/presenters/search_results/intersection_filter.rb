module SearchResults

  class IntersectionFilter < Filter

    def initialize(filter, params)
      @filter = filter
      @params = @prop_params = params
      @depth_0_vals, @depth_1_vals = intersect(@filter.depth_0_vals, @filter.depth_1_vals)
    end

    def depth_0_prop_ids
      @prop_params[Depth::PARENT]
    end

    def depth_1_prop_ids
      @prop_params[Depth::CHILD]
    end

    private

    def intersect(depth_0_vals, depth_1_vals)
      # Calling "to_a" because of bug in rails when calling empty?/any? on relation not yet loaded
      # Fixed at https://github.com/rails/rails/commit/015192560b7e81639430d7e46c410bf6a3cd9223
      if depth_1_vals.to_a.any?
        depth_1_vals  = filter_depth_1_vals_by_selected_ling_parents(depth_0_vals, depth_1_vals)
        depth_0_vals  = filter_depth_0_vals_by_filtered_depth_1_vals(depth_0_vals, depth_1_vals)
      end
      [depth_0_vals, depth_1_vals]
    end

    def filter_depth_1_vals_by_selected_ling_parents(depth_0_vals, depth_1_vals)
      LingsProperty.select_ids.with_id(depth_1_vals.map(&:id)).where(:property_id => depth_1_prop_ids) &
        Ling.parent_ids.with_parent_id(depth_0_vals.map(&:ling_id).uniq)
    end

    def filter_depth_0_vals_by_filtered_depth_1_vals(depth_0_vals, depth_1_vals)
      LingsProperty.select_ids.with_id(depth_0_vals.map(&:id)).
        with_ling_id(depth_1_vals.map(&:parent_id).uniq).where(:property_id => depth_0_prop_ids)
    end
  end

end