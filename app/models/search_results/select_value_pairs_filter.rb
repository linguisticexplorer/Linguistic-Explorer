module SearchResults

  class SelectValuePairsFilter < Filter

    def depth_0_vals
      @depth_0_vals ||= filter_vals(Depth::PARENT)
    end

    def depth_1_vals
      @depth_1_vals ||= filter_vals(Depth::CHILD)
    end

    private

    def filter_vals(depth)
      cross_disabled = @query.category_ids_by_cross_grouping_and_depth(:property_set, depth).empty?
      vals  = @filter.vals_at(depth)
      pairs = @query.lings_props_pairs(depth)

      if pairs.any? && cross_disabled
         LingsProperty.select_ids.where({ :property_value => pairs } & {:id => vals})
      else
        vals
      end
    end

  end

end