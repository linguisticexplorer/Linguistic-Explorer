module SearchResults

  class IntersectionFilter < Filter

    def initialize(filter, query)
      super
      @depth_0_vals, @depth_1_vals = intersect @filter

    end

    private

    def intersect(filter)
      d_0_vals, d_1_vals = [@filter.depth_0_vals, @filter.depth_1_vals]

      # If depth 1 is not interesting this work is useless
      if is_depth_1_interesting? && d_1_vals.any?
        d_1_vals  = filter_depth_1_vals_by_selected_ling_parents  d_0_vals, d_1_vals
        d_0_vals  = filter_depth_0_vals_by_filtered_depth_1_vals  d_0_vals, d_1_vals
      end
      
      [d_0_vals, d_1_vals]
    end

    def filter_depth_1_vals_by_selected_ling_parents(depth_0_vals, depth_1_vals)
      return [] if any_error? depth_1_vals
      val_ids         = depth_1_vals.map(&:id).uniq
      parent_ling_ids = depth_0_vals.map(&:ling_id).uniq
      # val_ids         = depth_1_vals.pluck(:id).uniq
      # parent_ling_ids = depth_0_vals.pluck(:ling_id).uniq 


      result = LingsProperty.select_ids.
        with_id(val_ids).
        where(:property_id => prop_ids(Depth::CHILD)).
        includes(:ling).
        merge Ling.parent_ids.with_parent_id(parent_ling_ids)

      return result
    end

    def filter_depth_0_vals_by_filtered_depth_1_vals(depth_0_vals, depth_1_vals)
      return [] if any_error? depth_1_vals
      val_ids         = depth_0_vals.map(&:id).uniq
      parent_ling_ids = depth_1_vals.map(&:parent_ling_id).uniq
      # val_ids         = depth_0_vals.pluck(:id).uniq
      # parent_ling_ids = depth_1_vals.pluck(:parent_id).uniq 

      result = LingsProperty.select_ids.
        with_id(val_ids).
        with_ling_id(parent_ling_ids).
        where(:property_id => prop_ids(Depth::PARENT))

      return result
    end

    def prop_ids(depth)
      @filter.vals_at(depth).map(&:property_id).uniq
    end

    def is_depth_1_interesting?
      @query.is_depth_1_interesting?
    end

  end

end