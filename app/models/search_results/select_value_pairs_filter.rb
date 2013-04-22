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
      vals  = @filter.vals_at(depth)
      pairs = @query.lings_props_pairs(depth)

      if pairs.any? && value_pairs_search_enabled?
         # LingsProperty.select_ids.where({ :property_value => pairs } & {:id => vals})
         # Using the Squeel format
         LingsProperty.select_ids.where{ (:property_value == my{pairs} ) & (:id == my{vals} )}
      else
        vals
      end
    end

    def value_pairs_search_enabled?
      !@query.is_cross_search?
    end

  end

end