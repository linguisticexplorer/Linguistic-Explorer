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

      def self.vals_by_prop_values_filtered(to_be_filtered, accepted_values)
        vals_by_prop_values(to_be_filtered).reject {|prop_val,lings| !accepted_values.include?(prop_val)}
      end

      def self.all_prop_values(ling_ids)
        LingsProperty.with_ling_id(ling_ids).select("DISTINCT(property_value), id").group_by(&:property_value)
      end

      def self.find_antecedents(ids)
        prop_values_selected = LingsProperty.select_ids.group(:property_value).having(["COUNT(property_value) <= ?", ids.size+1]).map(&:property_value)
        LingsProperty.select_ids.where(:property_value => prop_values_selected).group_by(&:property_value)
      end

      def self.equals_or_included(big_set, small_set)
        return true if big_set.sort == small_set.sort
        small_set.all? {|ling_id| big_set.include?(ling_id)}
      end

      # Idea: make a both on all and filter subset_val_ids with
      # prop_values retrieved by the search
      def self.find_implications(vals)
        {}.tap do |groups|
          group = get_group(vals)
          cache_by_prop_value = vals_by_prop_values(vals)

          # For each cons_prop:
          #  find all lings with this prop, call it SBL (SuBsetLings)
          #  find all props group by props and filter by lings number (should be equal or less than SBL)
          #  check lings for each prop is a subset of SBL
          prop_values_in(cache_by_prop_value).each do |prop_value|
            subset_ling_ids = filter_ling_ids(group, prop_value)

            antecedents = find_antecedents(subset_ling_ids).reject {|pv, lps| pv==prop_value }
            antecedents = antecedents.select { |pv, lps| equals_or_included(subset_ling_ids, lps.map(&:ling_id))}

            antecedents.each_value do |prop|
              parent_id = [prop,cache_by_prop_value[prop_value]].map(&:first).map(&:id)
              groups[parent_id] = prop.map(&:id)
            end
          end
        end
      end
      
    end
  end
end