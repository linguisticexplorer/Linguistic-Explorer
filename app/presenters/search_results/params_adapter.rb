module SearchResults

  class ParamsAdapter
    attr_reader :group

    def initialize(group, params)
      @group  = group
      @params = params
    end

    def [](key)
      @params[key]
    end

    def lings
      self[:lings] || {}
    end

    def lings_props
      self[:lings_props] || {}
    end

    def properties
      self[:properties] || {}
    end
    
    def group_id
      @group_id ||= @group.id
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

    def selected_value_pairs(category_id)
      lings_props[category_id.to_s]
    end

    def selected_property_ids(category_id)
      properties[category_id.to_s]
    end

    def group_prop_category_ids(depth)
      Category.ids_by_group_and_depth(@group, depth)
    end

    def lings_props_pairs(depth)
      # {"8"=>["15:verb"]} --> [["15", "verb"]]
      lings_props.select { |k,v| category_present?(k, depth) }.values.flatten
    end

    def properties_by_depth
      return properties if properties.empty?
      result = {}.tap do |hash|
        Depth::DEPTHS.each do |depth|
          hash[depth.to_s] = group_prop_category_ids(depth).inject([]) do |memo, id|
            memo << properties[id.to_s]
          end.flatten.compact
        end
      end.delete_if {|k,v| v.empty? }
    end

    def category_ids_by_all_grouping_and_depth(grouping, depth)
      group_prop_category_ids(depth).select { |c|
        category_ids_by_all_grouping(grouping).include?(c)
      }
    end

    def has_depth?
      @group.has_depth?
    end

    private

    def ling_extractor
      @ling_extractor ||= LingExtractor.new(@group, lings)
    end

    def prop_extractor
      @prop_extractor ||= PropertyExtractor.new(@group, properties_by_depth)
    end

    def category_ids_by_all_grouping(grouping)
      # {"1"=>"all", "2"=>"any"} --> [1]
      category_all_pairs = self[grouping].group_by { |k,v| v }["all"] || []
      category_all_pairs.map { |c| c.first }.map(&:to_i)
    end

    def category_present?(key, depth)
      group_prop_category_ids(depth).map(&:to_s).include?(key)
    end
    
    def included_columns
      # {"ling_0"=>"1", "ling_1"=>"1", "prop"=>"1", "value"=>"1"}
      @params[:include].symbolize_keys.keys
    end

  end

  class ParamExtractor
    def initialize(group, params = {})
      @group, @params = group, params
    end

    def ids(depth)
      selected(depth) || []
    end

    def selected(depth)
      params[depth.to_s]
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