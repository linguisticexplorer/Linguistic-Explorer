module SearchResults

  class CategorizedParamsAdapter
    def initialize(group)
      @group = group
    end

    def group_prop_category_ids(depth)
      Category.ids_by_group_and_depth(@group, depth)
    end

    def val_params_to_pairs(depth, params)
      vals = params.reject { |k,v| !category_present?(k, depth) }.values
      vals.flatten.map { |str| str.split(":") }
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