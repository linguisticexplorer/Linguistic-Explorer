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

    private

    def filter_vals(vals, depth)
      pairs = val_params_to_pairs(depth)
      if pairs.any?
        LingsProperty.select_ids.where(val_conditions(pairs) & {:id => vals})
      else
        vals
      end
    end

    def val_conditions(pairs)
      conditions = pairs.inject({:id => nil}) do |conds, pair|
        conds | { :property_id => pair.first, :value => pair.last }
      end
    end

    def val_params_to_pairs(depth)
      # {"8"=>["15:verb"]} --> [["15", "verb"]]
      vals = @params.reject { |k,v| !@adapter.category_present?(k, depth) }.values
      vals.flatten.map { |str| str.split(":") }
    end
  end

end