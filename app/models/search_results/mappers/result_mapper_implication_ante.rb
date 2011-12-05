module SearchResults

  module Mappers

    class ResultMapperImplicationAnte < ResultMapperImplicationBoth

      private

      def self.filter_ling_ids(group, prop_value)
        LingsProperty.in_group(group).select("ling_id").where("property_value = ?", prop_value).index_by(&:ling_id).keys
      end

      def self.find_implications(vals)
        {}.tap do |groups|
          group = get_group(vals)

          cache_by_prop_value = vals_by_prop_values(vals)

          prop_values_in(cache_by_prop_value).each do |prop_value|
            subset_ling_ids = filter_ling_ids(group, prop_value)
            common_props = common_values_in_subset(subset_ling_ids).reject {|pv| pv==prop_value}

            common_props.each_value do |props|
              parent_id = [cache_by_prop_value[prop_value],props].map(&:first).map(&:id)
              groups[parent_id] = props.map(&:id)
            end
          end
        end
      end

    end
  end
end