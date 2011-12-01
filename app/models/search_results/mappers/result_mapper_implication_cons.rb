module SearchResults

  module Mappers
    
    class ResultMapperImplicationCons < ResultMapperImplicationBoth
      
      private

      def self.filter_ling_ids(group, prop_value)
        LingsProperty.in_group(group).select("ling_id").where("property_value" => prop_value).index_by(&:ling_id).keys
      end

      def self.lings_subset(ling_ids)
        LingsProperty.with_ling_id(ling_ids).group_by(&:ling_id)
      end

      def self.get_group(vals)
        vals.empty? ? -1 : vals.values.first.first.group
      end

      def self.vals_by_prop_values_filtered(to_be_filtered, accepted_values)
        vals_by_prop_values(to_be_filtered).reject {|prop_val,lings| !accepted_values.include?(prop_val)}
      end

      def self.all_prop_values(ling_ids)
        LingsProperty.with_ling_id(ling_ids).select("DISTINCT(property_value), id").group_by(&:property_value)
      end

      # Idea: make a both on all and filter subset_val_ids with
      # prop_values retrieved by the search
      def self.find_implications(vals)
        {}.tap do |groups|
          cache_by_prop_value = vals_by_prop_values(vals)
          consequent_prop_values = cache_by_prop_value.keys.uniq
          group = get_group(cache_by_prop_value)
          useful_lings_for_vals = filter_ling_ids(group, consequent_prop_values)

          all_vals_by_prop_values = all_prop_values(useful_lings_for_vals)

          all_vals_by_prop_values.keys.each do |prop_value|
            subset_ling_ids = filter_ling_ids(group, prop_value)

            subset_vals_by_ling_id = lings_subset(subset_ling_ids)

            subset_val_ids = val_ids_mapped(subset_vals_by_ling_id)

            # Filter prop_values from LingsProperties retrieved by vals_by_prop_values...
            vals_by_prop_value = vals_by_prop_values_filtered(subset_val_ids, consequent_prop_values).reject {|k,v| k==prop_value}

            common_props = vals_by_prop_value.reject {|prop_val,lings| lings.size != subset_vals_by_ling_id.keys.size }

            common_props.each_value do |props|
              parent_id = [all_vals_by_prop_values[prop_value],props].map(&:first).map(&:id)
              groups[parent_id] = props.map(&:id)
            end
          end
        end
      end
      
    end
  end
end