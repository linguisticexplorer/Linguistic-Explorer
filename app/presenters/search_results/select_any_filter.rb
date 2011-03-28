module SearchResults

  class SelectAnyFilter < Filter

    attr_reader :adapter

    def initialize(filter, params)
      @filter = filter
      @params = params
      @group  = @params.group
    end

    def depth_0_vals
      @depth_0_vals ||= LingsProperty.select_ids.where(:ling_id => depth_0_ling_ids, :property_id => depth_0_prop_ids)
    end

    def depth_1_vals
      @depth_1_vals ||= begin
        return [] unless depth_1_ling_ids.any?
        LingsProperty.select_ids.where(:ling_id => depth_1_ling_ids, :property_id => depth_1_prop_ids)
      end
    end

    def ling_extractor
      @ling_extractor ||= LingExtractor.new(@group, @params[:lings])
    end

    def prop_extractor
      @prop_extractor ||= PropertyExtractor.new(@group, @params.convert_to_depth_params(:properties))
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

    def selected_property_ids_by_depth(depth)
      @selected_property_ids_by_depth ||= { Depth::PARENT => depth_0_prop_ids, Depth::CHILD => depth_1_prop_ids }
      @selected_property_ids_by_depth[depth]
    end

    def val_params
      @params[:lings_props] || {}
    end

  end

  class ParamExtractor
    def initialize(group, params = {})
      @group, @params = group, params
    end

    def ids(depth)
      selected(depth) || all.at_depth(depth)
    end

    def selected(depth)
      params[depth.to_s]
    end

    def all
      @all ||= klass.ids.in_group(@group)
    end

    def params
      @params || {}
    end

    def depth_0_ids
      ids(Depth::PARENT)
    end

    def depth_1_ids
      ids(Depth::CHILD)
    end

    def klass
      /Ling|Property/.match(self.class.name)[0].constantize
    end
  end

  class LingExtractor < ParamExtractor
  end

  class PropertyExtractor < ParamExtractor
  end

end