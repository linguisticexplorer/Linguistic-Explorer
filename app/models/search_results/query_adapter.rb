module SearchResults

  class QueryAdapter

    attr_reader :group

    def initialize(group, params)
      @group  = group
      @params = (params || {}).symbolize_keys

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

    def included_columns
      # {"ling_0"=>"1", "ling_1"=>"1", "prop_0"=>"1", "value_0"=>"1"}
      # show all columns if parameters not present
      included ||= @params[:include] && @params[:include].symbolize_keys.keys

      included.nil? ? SearchColumns::COLUMNS : order_columns(SearchColumns::COLUMNS, included)
    end

    def is_depth_1_interesting?
      return depth_of_cross_search==Depth::CHILD if is_cross_search?
      return depth_of_compare_search==Depth::CHILD if is_compare_search?
      (included_columns & SearchColumns::CHILD_COLUMNS).any?
    end

    def is_cross_search?
      category_ids_by_cross_grouping(:property_set).any?
    end

    def is_special_search?
      is_cross_search? || is_compare_search?
    end

    def is_compare_search?
      depth_by_compare_grouping(:ling_set).any?
    end

    def depth_of_cross_search
      if is_cross_search?
        category_ids_by_cross_depth(0).any? ? Depth::PARENT : Depth::CHILD
      end
    end

    def depth_of_compare_search
      if is_compare_search?
        depth_by_compare_grouping(:ling_set).first.to_i
      end
    end

    def category_ids_by_cross_depth(depth)
      group_prop_category_ids(depth).select { |c|
        category_ids_by_cross_grouping(:property_set).include?(c)
      }
    end

    private

    def is_valid?
      return true unless is_special_search?

      if is_cross_search?
        sel_props = selected_properties_to_cross(depth_of_cross_search)
        # Raise an Exception if there are less properties than required
        raise Exceptions::ResultAtLeastTwoForCrossError if sel_props.size < 2 || properties.nil?
        # Avoid Cartesian Product with too many properties
        raise Exceptions::ResultTooManyForCrossError if sel_props.size > dynamic_threshold
      elsif is_compare_search?
        sel_lings = selected_lings_to_cross(depth_of_compare_search)
        raise Exceptions::ResultAtLeastTwoForCompareError if sel_lings.size < 2 || lings.nil?
      end
    end

    def selected_lings_to_cross(depth)
      lings[depth.to_s] || []
    end

    def dynamic_threshold
      # Two Properties for too many lps
      lings_property_in_group_number > 100000 ? 2 : Search::RESULTS_CROSS_THRESHOLD
    end

    def lings_property_in_group_number
      LingsProperty.in_group(@group).all.count
    end

    def ling_extractor
      @ling_extractor ||= LingExtractor.new(@group, lings)
    end

    def prop_extractor
      @prop_extractor ||= PropertyExtractor.new(@group, properties_by_depth)
    end

    def category_ids_by_all_grouping(grouping)
      # {"1"=>"all", "2"=>"any", "3"=>"cross"} --> [1]
      category_all_pairs = self[grouping].group_by { |k,v| v }["all"] || []
      category_all_pairs.map { |c| c.first }.map(&:to_i)
    end

    def category_ids_by_cross_grouping(grouping)
      # {"1"=>"all", "2"=>"any", "3"=>"cross"} --> [3]
      category_cross_pairs ||= [] if self[grouping].nil?
      category_cross_pairs ||= self[grouping].group_by { |k, v| v }["cross"] || []
      category_cross_pairs.map { |c| c.first }.map(&:to_i)
    end

    def depth_by_compare_grouping(grouping)
      # {"0"=>"compare"} --> [0]
      return [] if self[grouping].nil?
      self[grouping].select {|k,v| v=="compare"}.keys
    end

    def category_present?(key, depth)
      group_prop_category_ids(depth).map(&:to_s).include?(key)
    end

    def order_columns(fixed_array, params_array)
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