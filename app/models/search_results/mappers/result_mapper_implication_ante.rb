module SearchResults

  module Mappers

    class ResultMapperImplicationAnte < ResultMapperImplicationBoth

      private

      def self.filter_ling_ids(group, prop_value)
        LingsProperty.in_group(group).select("ling_id").where("property_value = ?", prop_value).index_by(&:ling_id).keys
      end

      def self.lings_subset(ling_ids)
        LingsProperty.with_ling_id(ling_ids).group_by(&:ling_id)
      end

      def self.get_group(vals)
        vals.empty? ? -1 : vals.values.first.first.group
      end

      def self.find_implications(vals)
        {}.tap do |groups|
          cache_by_prop_value = vals_by_prop_values(vals)
          group = get_group(cache_by_prop_value)
          prop_values_in(cache_by_prop_value).each do |prop_value|

            subset_ling_ids = filter_ling_ids(group, prop_value)

            subset_vals_by_ling_id = lings_subset(subset_ling_ids)

            subset_val_ids = val_ids_mapped(subset_vals_by_ling_id)
            vals_by_prop_value = vals_by_prop_values(subset_val_ids).reject {|k,v| k==prop_value}

            common_props = vals_by_prop_value.reject {|k,v| v.size != subset_vals_by_ling_id.keys.size }

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