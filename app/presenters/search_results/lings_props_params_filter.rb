module SearchResults

  class LingsPropsParamsFilter
    def initialize(group, params)
      @group, @params = group, params
    end

    def depth_0_vals
      LingsProperty.select_ids.where(:ling_id => depth_0_ling_ids, :property_id => depth_0_prop_ids)
    end

    def depth_1_vals
      return [] unless depth_1_ling_ids.any?
      LingsProperty.select_ids.where(:ling_id => depth_1_ling_ids, :property_id => depth_1_prop_ids)
    end
    
    def ling_extractor
      @ling_extractor ||= LingExtractor.new(@group, @params[:lings])
    end

    def prop_extractor
      @prop_extractor ||= PropertyExtractor.new(@group, @params[:properties])
    end

    def depth_0_ling_ids
      ling_extractor.depth_0_ids
    end

    def depth_1_ling_ids
      ling_extractor.depth_1_ids
    end

    def depth_0_prop_ids
      prop_extractor.depth_0_ids
    end

    def depth_1_prop_ids
      prop_extractor.depth_1_ids
    end

  end

end