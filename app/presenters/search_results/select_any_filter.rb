module SearchResults

  class SelectAnyFilter < Filter

    def initialize(params)
      @params = params
      @group  = @params.group
    end

    def depth_0_vals
      @depth_0_vals ||= begin
        LingsProperty.select_ids.where({
          :ling_id      => @params.depth_0_ling_ids,
          :property_id  => @params.depth_0_prop_ids
        })
      end
    end

    def depth_1_vals
      @depth_1_vals ||= begin
        return [] unless @params.depth_1_ling_ids.any?
        LingsProperty.select_ids.where({
          :ling_id => @params.depth_1_ling_ids,
          :property_id => @params.depth_1_prop_ids
        })
      end
    end

    def val_params
      @params[:lings_props] || {}
    end

  end

end