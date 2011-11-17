module SearchResults

  module Mappers
    class ResultMapperCompare < ResultMapper

      def self.build_result_groups(result)
        vals = LingsProperty.with_id(vals_ids_for_compare(result))
        vals_by_prop_ids = vals_by_property_id(vals)

        {}.tap do |groups|
          vals_by_prop_ids.keys.each do |prop_id|
            props = vals_by_prop_ids[prop_id]
            groups[props.first.id] = compare_property_value props
          end
          groups["type"]="compare"
        end
      end

      def to_flatten_results
        @flatten_results ||= [].tap do |entry|
          result_groups.each do |parent_id, children_ids|
            parent            = parents.select {|parent| parent.id.to_i == parent_id.to_i}
            related_children  = children.select {|child| child.map(&:id).sort == children_ids.sort }.flatten
            entry << ResultEntry.new(parent, related_children)
          end
        end.sort_by {|result| result.child.size}
      end

      def parents
        @parents ||= LingsProperty.with_id(parent_ids).joins(:property).
            includes([:property]).order("properties.name")
      end

      def children
        @children ||= [].tap do |child|
          all_child_ids.each do |children_ids|
            child << LingsProperty.with_id(children_ids).joins(:ling, :property).includes([:ling, :property])
          end
        end
      end

      private

      def self.depth_for_compare(result)
        result.depth_for_compare
      end

      def self.vals_ids_for_compare(result)
        is_parent?(depth_for_compare(result)) ? result.parent : result.child
      end

      def self.compare_property_value(vals)
        prop_values = vals.map(&:property_value).uniq

        prop_values.count == 1 ? [vals.map(&:id).first] : vals.map(&:id)
      end

    end
  end
end