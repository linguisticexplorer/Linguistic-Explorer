module SearchResults

  module Mappers

    class ResultMapperClusteringHamming < ResultMapper

      def self.build_result_groups(result)
        parent_vals = LingsProperty.with_id(result.parent)

        lps_by_ling_id = vals_by_ling_id(parent_vals)

        prop_ids = vals_by_property_id(parent_vals).keys

        {}.tap do |row|
          lps_by_ling_id.each do |ling_id, lps|
            props_row = []
            prop_ids.each do |prop|
              if lps.map(&:property_value).include? "#{prop}:Yes"
                props_row << 1
                # Include this property but the value is something different from Yes
              elsif lps.map(&:prop_id).include?(prop)
                props_row << -1
              else
                props_row << 0
              end
            end
            row[ling_id] = props_row
          end
          row[:prop_ids] = prop_ids
        end
      end

      def to_flatten_results
        matrix_to_cluster = map_ling_names result_groups
        @flatten_result ||= []
        # if legacy_browser?
        #plotter = Plotter::LegacyPlotter.new(matrix_to_cluster)
        #@flatten_result << :legacy
        # else
        plotter = Plotter::D3jsPlotter.new(matrix_to_cluster)
        # @flatten_result << radial_tree? ? :d3_radial_tree : :d3_phylogram
        @flatten_result << :d3js
        # end
        plotter.plot_it!
        @flatten_result << [plotter.path_to_img]
      end

      def parent_ids
        result_groups.keys.reject {|k| k.is_a? Symbol}
      end

      def parents
        @parents ||= Ling.where(:id => parent_ids).index_by(&:id)
      end

      private

      # This method will create a new Hash ad map for each id this ling name
      # E.g.
      # 751 => [1,0,0]
      # becomes
      # 'Aymara' => [1,0,0]
      def map_ling_names(hash)
        {}.tap do |row|
          hash.each do |k, v|
            if k.is_a? Symbol
              row[:prop_ids] = v
            else
              row[parents[k].name] = v
            end
          end
        end
      end


    end
  end
end