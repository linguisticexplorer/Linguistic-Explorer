module SearchResults

  class SelectAnyFilter < Filter

    def initialize(params)
      @params = params
    end

    def depth_0_vals
      @depth_0_vals ||= begin
        lings_property_where conditions_at_depth(Depth::PARENT)
      end
    end

    def depth_1_vals
      @depth_1_vals ||= begin
        return [] unless @params.has_depth?
        lings_property_where conditions_at_depth(Depth::CHILD)
      end
    end

    private

    def lings_property_where(conditions)
      LingsProperty.select_ids.where conditions
    end

    def conditions_at_depth(depth)
      conditions = {}.tap do |c|
        ling_ids        = ling_ids(depth)
        prop_ids        = prop_ids(depth)
        c[:ling_id]     = ling_ids if ling_ids.any?
        c[:property_id] = prop_ids if prop_ids.any?
      end
    end

    def ling_ids(depth)
      @params.send("depth_#{depth}_ling_ids")
    end

    def prop_ids(depth)
      @params.send("depth_#{depth}_prop_ids")
    end
  end

end