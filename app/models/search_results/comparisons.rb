module SearchResults
  module Comparisons
    attr_reader :search_comparison

    def result_rows=(result_rows)
      self.result_groups = result_rows.group_by { |row| row.parent_id }
      self.result_groups.values.map! { |row| row.map! { |r| r.child_id }.compact! }
      @search_comparison = true
    end

    def result_rows(parent_attr_names, child_attr_names = [])
      [].tap do |rows|
        # Rails.logger.debug "[DEBUG] #{self.results.inspect}"
        self.results.each do |result|
          parent, child = result.parent, result.child
          next unless parent
          parent_map = parent.column_map(parent_attr_names)
          if child.nil?
            rows << ResultRow.new(parent_map)
          else
            rows << ResultRow.new(parent_map, child.column_map(child_attr_names))
          end
        end
      end
    end

    class ResultRow
      # parent_map is array of [parent_id, attrs*]
      # child_map is array of [child_id, attrs*]
      def initialize(parent_map, child_map = [])
        @parent_map, @child_map = parent_map, child_map
      end

      def attrs
        # include all but first column in map (id)
        (parent_attrs + child_attrs).compact
      end

      def parent_attrs
        ((@parent_map.slice(1, @parent_map.length)) || []).compact
      end

      def child_attrs
        ((@child_map.slice(1,@child_map.length)) || []).compact
      end

      def eql?(result_row)
        attrs == result_row.attrs
      end

      def hash
        attrs.hash
      end

      def parent_id
        @parent_map[0]
      end

      def child_id
        @child_map[0]
      end
    end
    
  end
end