module SearchResults

  module Mappers
    class ResultMapperCross < ResultMapper

      def self.build_result_groups(result)

        vals = LingsProperty.with_id(vals_ids_for_cross(result))
        vals_by_prop_ids = vals_by_property_id(vals)

        p "FIRST: #{result.inspect} - #{vals}"

        prop_values = [].tap do |p|
          vals_by_prop_ids.keys.each do |prop_id|
            p << vals_by_prop_ids[prop_id].map(&:property_value).uniq
          end
        end

        first_prop = prop_values.first
        rest_props = prop_values.drop(1)

        p "SECOND: #{first_prop.inspect} + #{vals_by_prop_ids.inspect} = #{prop_values.inspect}"

        combinations = first_prop.product(*rest_props)

        combinations.each do |c|
          c.map! do |prop_value|
            LingsProperty.find_by_property_value(prop_value)
          end
        end

        {}.tap do |groups|
          combinations.map do |comb_parents|
            comb_parent_ids = comb_parents.map {|p| p.id.to_i}
            groups[comb_parent_ids] = lings_ids_in_combination(vals, comb_parents).map(&:id)
          end
        end
      end

      def to_flatten_results
        @flatten_results ||= [].tap do |entry|
          pre_loading_data
          result_groups.each do |parent_ids, children_ids|
            parent = parent_ids.map {|id| parents[id]}
            related_children = children_ids.map {|id| children[id]}
            entry << ResultEntry.new(parent, related_children)
          end
        end
        flatten_results_sorted_by_count_and_names
      end

      def parents
        @parents ||= LingsProperty.with_id(parent_ids.flatten).includes(:property).index_by(&:id)
      end

      def children
        @children ||= LingsProperty.with_id(all_child_ids).joins(:ling).index_by(&:id)
      end

      private

      def flatten_results_sorted_by_count_and_names
        @flatten_results.sort_by {|entry| [-entry.child.size, *(entry.parent.map(&:prop_name))]}
      end

      def self.depth_for_cross(result)
        result.depth_for_cross
      end

      def self.vals_ids_for_cross(result)
        is_parent?(depth_for_cross(result)) ? result.parent : result.child
      end

      def self.lings_ids_in_combination(vals, combination)
        lings_ids = vals_by_ling_id(vals)

        lings_ids.select do |ling|
          combination.map {|lp| lp.property_value.to_s}.
              all? { |value| ling_with_combination?(lings_ids[ling], value) }
        end.values.map(&:first)
      end

      def self.ling_with_combination?(ling_props, value)
        ling_props.select { |lp| lp.property_value == value}.any?
      end

    end
  end
end