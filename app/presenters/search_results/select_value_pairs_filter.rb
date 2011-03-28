module SearchResults

  class SelectValuePairsFilter < Filter
    def initialize(filter, params)
      @filter   = filter
      @params   = params
    end
    delegate  :group_prop_category_ids,
              :selected_property_ids_by_depth, :to => :filter

    def depth_0_vals
      @depth_0_vals ||= filter_vals(@filter.depth_0_vals, Depth::PARENT)
    end

    def depth_1_vals
      @depth_1_vals ||= filter_vals(@filter.depth_1_vals, Depth::CHILD)
    end

    def selected_lings_properties_by_depth(depth)
      @selected_lings_properties_by_depth ||= { Depth::PARENT => depth_0_vals.map(&:id), Depth::CHILD => depth_1_vals.map(&:id) }
      @selected_lings_properties_by_depth[depth]
    end

    private

    def filter_vals(vals, depth)
      pairs = val_params_to_pairs(depth)
      if pairs.any?
        LingsProperty.select_ids.where({ :property_value => pairs } & {:id => vals})
      else
        vals
      end
    end

    def val_params_to_pairs(depth)
      # {"8"=>["15:verb"]} --> [["15", "verb"]]
      vals = @params.reject { |k,v| !@filter.category_present?(k, depth) }.values
      vals.flatten
    end
  end

end