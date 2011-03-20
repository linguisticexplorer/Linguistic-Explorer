module SearchResults

  class ValuePairParamsFilter
    def initialize(filter, adapter, params)
      @filter   = filter
      @adapter  = adapter
      @params   = params
    end

    def depth_0_vals
      filter_vals(@filter.depth_0_vals, Depth::PARENT)
    end

    def depth_1_vals
      filter_vals(@filter.depth_1_vals, Depth::CHILD)
    end

    def filter_vals(vals, depth)
      if value_pairs_at_depth(depth).any?
        LingsProperty.ids.where(val_conditions(depth) & {:id => vals})
      else
        vals
      end
    end

    def val_conditions(depth)
      conditions = value_pairs_at_depth(depth).inject({:id => nil}) do |conds, pair|
        conds | { :property_id => pair.first, :value => pair.last }
      end
    end

    def value_pairs_at_depth(depth)
      @adapter.val_params_to_pairs(depth, @params)
    end

  end

end