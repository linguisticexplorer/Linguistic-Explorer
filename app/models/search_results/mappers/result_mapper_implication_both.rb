module SearchResults

  module Mappers
    class ResultMapperImplicationBoth < ResultMapperCross

      def self.build_result_groups(result)

        if too_many_for_implication?(result)
          raise Exceptions::ResultTooManyForImplicationError
        end
        parent_vals  = lings_properties_in result.parent
        parent_groups = {}
        if parent_vals.any?
          parent_groups = find_implications(parent_vals)
        end

        child_vals = lings_properties_in result.child

        child_groups = {}
        if child_vals.any?
          child_groups = find_implications(child_vals)
        end

        result_groups = child_groups.merge parent_groups

        result_groups.reject {|k,v| v.empty?}
      end

      private

      def self.too_many_for_implication?(result)
        group = LingsProperty.with_id(result.parent).first.group
        ling_props_size = LingsProperty.in_group(group).count
        if ling_props_size > Search::RESULTS_FLATTEN_THRESHOLD
          if result.parent.size > 2000 || result.child.size > 2000
            raise Exceptions::ResultTooManyForImplicationError
          end
        end
        false
      end

      def self.lings_properties_in(ids)
        LingsProperty.with_id(ids)
      end

      def self.lings_subset(vals, ling_ids)
        vals_by_ling_id(vals).select {|k,v| ling_ids.include?(k)}
      end

      def self.prop_values_in(vals)
        vals.keys.uniq
      end

      def self.prop_values_in_subset(val_ids)
        LingsProperty.with_id(val_ids).select("DISTINCT(property_value)").map(&:property_value).uniq
      end

      def self.common_values_in_subset(ling_ids, prop_values_filtered=nil)
        result = LingsProperty.select_ids.where(:ling_id => ling_ids).group(:property_value).having(["COUNT(property_value) = ?", ling_ids.size])
        result = result.where(:property_value => prop_values_filtered) unless prop_values_filtered.nil?

        LingsProperty.with_ling_id(ling_ids).where("property_value" => result.map(&:property_value)).group_by(&:property_value)
      end

      def self.vals_by_prop_values(val_ids)
          LingsProperty.with_id(val_ids).group_by(&:property_value)
      end

      def self.filter_ling_ids(vals_by_prop_value, prop_value)
        vals_by_prop_value[prop_value].map(&:ling_id)
      end

      def self.get_group(vals)
        vals.first.group
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

            common_props = common_values_in_subset(subset_ling_ids, prop_values_in(cache_by_prop_value))

            # Don't forget to remove the property_value within common_props
            common_props = common_props.reject {|pv| pv==prop_value}

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