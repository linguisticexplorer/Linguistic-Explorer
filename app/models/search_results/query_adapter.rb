module SearchResults

  class QueryAdapter

    include SpecialSearchQueryAdapter

    attr_reader :group

    def initialize(group, params)
      @group  = group
      @params = (params || {}).symbolize_keys
      
      # due a rails 3.2 bug we have to clean multiselect
      # results from blank first-value in array
      @params.each do |k,v|
        case v
        when Array then v.reject!(&:blank?)
        when Hash then clean_select_multiple_params(v)
        end
      end

      is_valid?
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
      lings_props[category_id.to_s] || []
    end

    def selected_property_ids(category_id)
      properties[category_id.to_s] || []
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
      {}.tap do |hash|
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

    def selected_properties_to_cross(depth)
      selected_property_ids(category_ids_by_cross_depth(depth).first)
    end

    def has_depth?
      @group.has_depth?
    end

    def included_columns(impl=false)
      # {"ling_0"=>"1", "ling_1"=>"1", "prop_0"=>"1", "value_0"=>"1"}
      # show all columns if parameters not present
      included ||= @params[:include] && @params[:include].symbolize_keys.keys

      return included if impl

      included.nil? ? SearchColumns::COLUMNS : order_columns(SearchColumns::COLUMNS, included)
    end

    def is_depth_1_interesting?
      return depth_of_cross_search==Depth::CHILD if is_cross_search?
      return depth_of_compare_search==Depth::CHILD if is_compare_search?
      (included_columns & SearchColumns::CHILD_COLUMNS).any?
    end

    private

    def clean_select_multiple_params(hash)
      hash.each do |k,v|
        case v
        when Array then v.reject!(&:blank?)
        end
      end
    end

    def is_valid?
      return true unless is_special_search?
      is_special_search_valid?
    end

    def lings_property_in_group_number
      LingsProperty.in_group(@group).count
    end

    def ling_extractor
      @ling_extractor ||= LingExtractor.new(@group, lings)
    end

    def prop_extractor
      @prop_extractor ||= PropertyExtractor.new(@group, properties_by_depth)
    end

    def category_ids_by_all_grouping(grouping)
      # {"1"=>"all", "2"=>"any", "3"=>"cross"} --> [1]
      category_all_pairs = self[grouping] && self[grouping].group_by { |k,v| v }["all"] || []
      category_all_pairs.map { |c| c.first }.map(&:to_i)
    end

    def category_present?(key, depth)
      group_prop_category_ids(depth).map(&:to_s).include?(key)
    end

    def order_columns(fixed_array, params_array)
      params_array = filter_default_columns params_array

      hash_fixed = positions_hash fixed_array
      hash_params = positions_hash params_array
      hash_params.each do |key, value|
        if value != hash_fixed[key]
          old = hash_params.key(hash_fixed[key])
          hash_params[old] = value unless old.nil?
          hash_params[key] = hash_fixed[key]
        end
      end

      index_ordered = hash_params.invert.keys.sort
      [].tap do |included|
        index_ordered.each do |index_col|
          included << hash_params.key(index_col)
        end
      end
    end

    def positions_hash(array)
      hash = {}
      array.each do |key|
        hash[key] = array.index(key)
      end
      return hash
    end

    def filter_default_columns(params_array)
      params_array.reject {|column| column.to_s =~ /depth_/}
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