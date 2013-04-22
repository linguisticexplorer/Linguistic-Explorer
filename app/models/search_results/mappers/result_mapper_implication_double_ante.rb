module SearchResults

  module Mappers
    
    class ResultMapperImplicationDouble < ResultMapperImplicationCons
      
      private

      def self.find_antecedents(ids)
        prop_values_selected_in_all = LingsProperty.select_ids.group(:property_value).having(["COUNT(property_value) = ?", ids.size]).count

        prop_values_selected_in_ids = LingsProperty.with_ling_id(ids).select_ids.group(:property_value).having(["COUNT(property_value) = ?", ids.size]).count

        prop_values_antecedents = intersect prop_values_selected_in_all, prop_values_selected_in_ids

        # LingsProperty.select_ids.where(:property_value => prop_values_antecedents.keys).group_by(&:property_value)
        # Squeel Syntax
        LingsProperty.select_ids.where{ (:property_value == my{prop_values_antecedents.keys} )}.group_by(&:property_value)
      end

      def self.find_implications(vals)
        {}.tap do |groups|
          group = get_group(vals)
          cache_by_prop_value = vals_by_prop_values(vals)

          # For each cons_prop:
          #  find all lings with this prop, call it SBL (SuBsetLings)
          #  find all props group by props and filter by lings number (should be equal than SBL)
          #  check lings for each prop is a subset of SBL
          prop_values_in(cache_by_prop_value).each do |prop_value|
            subset_ling_ids = filter_ling_ids(group, prop_value)

            antecedents = find_antecedents(subset_ling_ids).reject {|pv, lps| pv==prop_value }
            antecedents.each_value do |prop|
              prop.sort_by! {|p| p.id }
              parent_id = [prop,cache_by_prop_value[prop_value]].map(&:first).map(&:id).sort
              groups[parent_id] ||= prop.map(&:id)
            end
          end
        end
      end

    end
  end
end