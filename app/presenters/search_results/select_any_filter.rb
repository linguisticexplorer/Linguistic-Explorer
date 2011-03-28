module SearchResults

  class SelectAnyFilter < Filter

    attr_reader :adapter

    def initialize(params)
      @group  = params.delete(:group)
      @filter = @adapter = CategorizedParamsAdapter.new(@group)
      @params = params
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
      @prop_extractor ||= PropertyExtractor.new(@group, convert_to_depth_params(@params[:properties]))
    end

    def selected_property_ids(category_id)
      @params[:properties][category_id.to_s]
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

  class CategorizedParamsAdapter
    def initialize(group)
      @group = group
    end

    def group_prop_category_ids(depth)
      Category.ids_by_group_and_depth(@group, depth)
    end

    def category_present?(key, depth)
      group_prop_category_ids(depth).map(&:to_s).include?(key)
    end

    def convert_to_depth_params(categorized_params = nil)
      return {} if categorized_params.nil?
      result = {}.tap do |hash|
        Depth::DEPTHS.each do |depth|
          hash[depth.to_s] = group_prop_category_ids(depth).inject([]) do |memo, id|
            memo << categorized_params[id.to_s]
          end.flatten.compact
        end
      end.delete_if {|k,v| v.empty? }
    end

  end

end