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

    def lings_props
      self[:lings_props] || {}
    end

    def properties
      self[:properties] || {}
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

    def convert_to_depth_params(key)
      categorized_params = @params[key]
      return {} if categorized_params.nil?
      result = {}.tap do |hash|
        Depth::DEPTHS.each do |depth|
          hash[depth.to_s] = group_prop_category_ids(depth).inject([]) do |memo, id|
            memo << categorized_params[id.to_s]
          end.flatten.compact
        end
      end.delete_if {|k,v| v.empty? }
    end

    def category_ids_by_all_grouping_and_depth(grouping, depth)
      group_prop_category_ids(depth).select { |c|
        category_ids_by_all_grouping(grouping).include?(c)
      }
    end

    private

    def category_ids_by_all_grouping(grouping)
      # {"1"=>"all", "2"=>"any"} --> [1]
      category_all_pairs = self[grouping].group_by { |k,v| v }["all"] || []
      category_all_pairs.map { |c| c.first }.map(&:to_i)
    end

    def category_present?(key, depth)
      group_prop_category_ids(depth).map(&:to_s).include?(key)
    end

  end


end