module SearchResults

  class IntersectionFilter < Filter

    def initialize(filter, query)
      super
      @depth_0_vals, @depth_1_vals = intersect @filter
    end

    private

    def intersect(filter)
      d_0_vals, d_1_vals = [@filter.depth_0_vals, @filter.depth_1_vals]

      # Calling "to_a" because of bug in rails when calling empty?/any? on relation not yet loaded
      # Fixed at https://github.com/rails/rails/commit/015192560b7e81639430d7e46c410bf6a3cd9223

      # If depth 1 is not interesting this work is useless
      if is_depth_1_interesting? && d_1_vals.to_a.any?
        d_1_vals  = filter_depth_1_vals_by_selected_ling_parents  d_0_vals, d_1_vals
        d_0_vals  = filter_depth_0_vals_by_filtered_depth_1_vals  d_0_vals, d_1_vals
      end

      [d_0_vals, d_1_vals]
    end

    def filter_depth_1_vals_by_selected_ling_parents(depth_0_vals, depth_1_vals)
      return [] if any_error? depth_1_vals
      val_ids         = depth_1_vals.map(&:id).uniq
      parent_ling_ids = depth_0_vals.map(&:ling_id).uniq


      LingsProperty.select_ids.
        with_id(val_ids).
        where(:property_id => prop_ids(Depth::CHILD)) &
        Ling.parent_ids.with_parent_id(parent_ling_ids)
    end

    def filter_depth_0_vals_by_filtered_depth_1_vals(depth_0_vals, depth_1_vals)
      return [] if any_error? depth_1_vals
      val_ids         = depth_0_vals.map(&:id).uniq
      parent_ling_ids = depth_1_vals.map(&:parent_id).uniq

      LingsProperty.select_ids.
        with_id(val_ids).
        with_ling_id(parent_ling_ids).
        where(:property_id => prop_ids(Depth::PARENT))
    end

    def prop_ids(depth)
      @filter.vals_at(depth).map(&:property_id).uniq
    end

    def is_depth_1_interesting?
      @query.is_depth_1_interesting?
    end

  end

end