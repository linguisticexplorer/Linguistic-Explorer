module SearchResults

  module Mappers
    class ResultMapperClusteringHamming < ResultMapper

      def self.build_result_groups(result)
        Rails.logger.debug "DEBUG: Mapper Clustering Hamming started"
        parent_vals = LingsProperty.with_id(result.parent)

        lps_by_ling_id = vals_by_ling_id(parent_vals)

        prop_ids = vals_by_property_id(parent_vals).keys

        groups = {}.tap do |group|
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
            group[ling_id] = props_row
          end
          group["type"] = "clustering_hamming"
        end

        Rails.logger.debug "DEBUG: Mapper #{groups.inspect}"
        return groups
      end

      def to_flatten_results
        @flatten_results ||= [].tap do |entry|
          result_groups.each do |parent_id, children_ids|
            parent = parents[parent_id]
            related_children = children_ids
            entry << ResultEntry.new(parent, related_children)
          end
        end
      end

      def parents
       @parents ||= Ling.where(:id => parent_ids).index_by(&:id)
      end

    end
  end
end