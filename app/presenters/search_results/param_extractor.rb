module SearchResults
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