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
      pairs = @params.lings_props_pairs(depth)

      pairs.any? ? LingsProperty.select_ids.where({ :property_value => pairs } & {:id => vals}) : vals
    end

  end

end