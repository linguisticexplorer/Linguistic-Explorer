module SearchResults

  class SelectValuePairsFilter < Filter
    def initialize(filter, params)
      @filter   = filter
      @params   = params
    end
    delegate  :prop_params,
              :group_prop_category_ids, :to => :filter

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
      vals = @params.reject { |k,v| !@filter.category_present?(k, depth) }.values
      vals.flatten.map { |str| str.split(":") }
    end
  end

end