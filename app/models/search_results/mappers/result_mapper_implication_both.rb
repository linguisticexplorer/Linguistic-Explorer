module SearchResults

  module Mappers
    class ResultMapperImplicationBoth < ResultMapperCross

      def self.build_result_groups(result)

        vals  = LingsProperty.select_ids.with_id(result.parent |result.child)
        final_groups = find_implications(vals)

        final_groups["type"]="implication_both"
        final_groups.reject {|k,v| v.empty?}
      end

      private

      def self.lings_subset(vals, ling_ids)
        vals_by_ling_id(vals).select {|k,v| ling_ids.include?(k)}
      end

      def self.val_ids_mapped(vals)
        [].tap do |ids|
          vals.each_value {|value| ids << value.map(&:id) }
        end.uniq.flatten
      end

      def self.prop_values_in(vals)
        vals.keys.uniq
      end

      def self.vals_by_prop_values(val_ids)
        LingsProperty.with_id(val_ids).group_by(&:property_value)
      end

      def self.filter_ling_ids(vals_by_prop_value, prop_value)
       vals_by_prop_value[prop_value].map(&:ling_id)
      end

      # Algorithm:
      # For each prop_value in vals
      # take subset of lings that have that prop_value
      # take all vals from that subset and group them by prop_values
      # Now: for each prop_value should be one lp for ling
      # If the number of lp in one entry of the vals grouped by prop_value
      # is the same of the number of lings in the subset it means
      # that property should be in common.
      def self.find_implications(vals)
        {}.tap do |groups|
          cache_by_prop_value = vals_by_prop_values(vals)

          prop_values_in(cache_by_prop_value).each do |prop_value|
            subset_ling_ids = filter_ling_ids(cache_by_prop_value, prop_value)

            subset_vals_by_ling_id = lings_subset(vals, subset_ling_ids)

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