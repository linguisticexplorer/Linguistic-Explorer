module SearchResults

  module Mappers
    class ResultMapperCompare < ResultMapper

      def self.build_result_groups(result)
        vals = LingsProperty.with_id(vals_ids_for_compare(result))
        vals_by_prop_ids = vals_by_property_id(vals)

        ling_ids = result.chosen_lings.sort

        {}.tap do |groups|
          vals_by_prop_ids.each do |prop_id, props|
            # Ordered property values by lings grouped by LingsProperty:
            groups[props.first.id] = compare_property_value props, ling_ids
          end
          groups["ling_ids"]=ling_ids
        end
      end

      def to_flatten_results
        @flatten_results ||= [].tap do |entry|
          lings = get_ordered_lings_by_id(result_groups)
          result_groups.each do |parent_id, children_ids|
            parent            = parents.select {|parent| parent.id.to_i == parent_id.to_i}
            related_children = children.select {|child| are_same_ids?(child, children_ids) }.first
            # It's necessary to insert lings too because of pagination it is not
            # easy to predict which value will be in or out in a particular page
            entry << ResultEntryCompare.new(parent, related_children, lings)
          end
        end
        return @flatten_results if @flatten_results.size == 1
        @flatten_results.sort { |first, second| first.child.size <=> second.child.size }
      end

      def parents
        @parents ||= LingsProperty.with_id(parent_ids).joins(:property).
            includes([:property]).order("properties.name")
      end

      def children
        @children ||= [].tap do |child|
          all_child_ids.each do |children_ids|
            child << map_ids_with_children(children_ids)
          end
        end
      end

      def all_child_ids
        result_groups.values
      end

      private

      def get_ordered_lings_by_id(groups)
        # Rails.logger.debug "DEBUG: #{groups.inspect}"
        Ling.find(groups.delete("ling_ids")).to_a.sort {|l1, l2| l1.id <=> l2.id}
      end

      def are_same_ids?(child, children_ids)
        map_to_ids(child) == children_ids
      end

      def map_to_ids(child)
        child.map {|lp| lp.present? ? lp.id.to_i : nil}
      end

      def map_ids_with_children(children_ids)
        if children_ids.include?(nil)
          map_ids_with_lps(children_ids, retrieve_children_by_ids(children_ids))
        else
          retrieve_children_by_ids(children_ids.sort!).sort_by(&:id)
        end
      end

      def map_ids_with_lps(ids, lps)
        ids.map { |id| id ? select_lp_by_id(lps, id) : nil}
      end

      def select_lp_by_id(lps, id)
        lps.select {|lp| lp.id.to_i == id.to_i}.first
      end

      def retrieve_children_by_ids(ids)
        LingsProperty.with_id(ids).joins(:ling, :property).includes([:ling, :property]).to_a
      end

      def select_children(compare_ids)
        children.select {|child| child.map(&:id) == compare_ids }
      end

      def self.depth_for_compare(result)
        result.depth_for_compare
      end

      def self.vals_ids_for_compare(result)
        is_parent?(depth_for_compare(result)) ? result.parent : result.child
      end

      # Create hash where for each lp correspond the position in the final array
      def self.hash_of_final_positions(lings_ordered, vals)
        {}.tap do |ling|
          lings_ordered.each do |ling_id|
            lp = vals.select { |lp| lp.ling_id.to_i == ling_id.to_i }
            ling[lp] = lings_ordered.rindex(ling_id)
          end
        end
      end

      # Build the array based on position-value of the entry
      # Remember:
      #
      # array = []
      # array[1] = value
      # array.inspect => [nil, value]
      def self.fill_array_with_lp_ids(lings_hash)
        [].tap do |vals_to_fill|
          lings_hash.each do |lp, index|
            vals_to_fill[index] = lp.map(&:id).first
          end
        end
      end

      def self.compare_property_value(vals, lings_ordered)
        prop_values = vals.map(&:property_value)
        return [vals.map(&:id).first] if is_a_common_property(prop_values)

        full_size = lings_ordered.size
        lings_hash = hash_of_final_positions(lings_ordered, vals)

        vals_to_fill = fill_array_with_lp_ids(lings_hash)

        return vals_to_fill unless vals_to_fill.size < full_size

        # if the array is smaller than the one of lings, fill last entries with nil
        last_index = vals_to_fill.size - 1
        vals_to_fill.fill(nil, last_index, full_size)

      end

      def self.is_a_common_property(prop_values)
        # Check prop_size is just one entry
        criteria = prop_values.uniq.size == 1
        # Check prop_values has only duplicates
        criteria & (prop_values.size > prop_values.uniq.size)
      end

      class ResultEntryCompare < ResultEntry
        attr_reader :lings, :prop

        def initialize(parent, child=nil, lings)
          super parent, child
          @lings = lings
          @prop  = parent.first.property.attributes
        end

        def common?
          child.size==1
        end

        def as_json(options={})
          super(:include => [:property])
        end

      end
    end
  end
end