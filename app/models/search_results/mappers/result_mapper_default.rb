module SearchResults

  module Mappers
    class ResultMapperDefault < ResultMapper

      def self.build_result_groups(result)

        # Eager-loading for a fast response on a big set of data
        parent_results  = LingsProperty.select_ids.with_id(result.parent).
            includes(:property, :examples, :examples_lings_properties, :ling)

        child_results   = LingsProperty.with_id(result.child).includes([:ling]).
            joins(:ling).order("lings.parent_id, lings.name").
            includes(:property, :examples, :examples_lings_properties)

        parent_filtered_results, child_filtered_results = filter_results_by_columns(parent_results, child_results, result.columns)

        #group parents separately with each related child
        {}.tap do |groups|
          parent_filtered_results.each do |parent|
            related_children  = child_filtered_results.select { |child| child.parent_ling_id == parent.ling_id }
            groups[parent.id.to_i] = related_children.map(&:id).map(&:to_i)
          end
        end
      end

      def to_flatten_results
        @flatten_results ||= [].tap do |entry|
          pre_loading_data
          # Rails.logger.debug "[DEBUG] #{result_groups.inspect}"
          result_groups.each do |parent_id, child_ids|
            parent = parents[parent_id.to_i]
            related_children = child_ids.map {|id| children[id.to_i]}
            if related_children.any?
              related_children.each { |child| entry << ResultEntry.new(parent, child) }
            else
              entry << ResultEntry.new(parent)
            end
          end
        end
      end

      def parents
        @parents ||= LingsProperty.with_id(parent_ids).includes([:ling, :property, :examples, :examples_lings_properties]).index_by(&:id)
      end

      def children
        @children ||= begin
          all_child_ids.present? ? retrieve_children : []
        end
      end

      private

      def retrieve_children
        LingsProperty.with_id(all_child_ids).includes([:ling, :property, :examples, :examples_lings_properties]).index_by(&:id)
      end

      def self.filter_results_by_columns(parent_results, child_results, columns)
        filter = ColumnsFilter.new(columns)
        parent_filtered_results = parent_results.select { |r| r if filter.filter_result_by_column?(r, Depth::PARENT) }
        child_filtered_results = child_results.select { |r| r if filter.filter_result_by_column?(r, Depth::CHILD) }

        [parent_filtered_results, child_filtered_results]
      end

      class ColumnsFilter

        def initialize(columns)
          @columns ||= columns
          @selected ||= Hash.new
          @all_depth_0_columns = columns.all? {|col| col.to_s=~/0/ }
          @all_depth_1_columns = columns.all? {|col| col.to_s=~/1/ }
        end

        def filter_result_by_column?(result, family_role)
          depth = Depth::PARENT if is_parent_and_no_child_columns? family_role
          depth = Depth::CHILD if is_child_and_no_parent_columns? family_role
          depth.nil? ? depth : filter_by_columns(result, depth)
        end

        private

        def is_parent_and_no_child_columns?(family_role)
          !@all_depth_1_columns && family_role==Depth::PARENT
        end

        def is_child_and_no_parent_columns?(family_role)
          @all_depth_1_columns || !@all_depth_0_columns && family_role==Depth::CHILD
        end

        def filter_by_columns(result, depth)
          already_written?(
              [].tap do |index|
                @columns.each do |col|
                  index << result_mapping(col, result) if col.to_s=~/#{depth}/
                end
              end
          )
        end

        def already_written?(index)
          return false if index.empty?
          @selected[index]= @selected[index].nil? ? 0 : 1
          return @selected[index]== 0
        end

        def result_mapping(col, result)
          columns_mapping[col].call(result)
        end

        def columns_mapping
          {
              :ling_0_id  => lambda { |v| v.id },
              :ling_1_id  => lambda { |v| v.id },
              :ling_0     => lambda { |v| v.ling },
              :ling_1     => lambda { |v| v.ling },
              :property_0 => lambda { |v| v.property },
              :property_1 => lambda { |v| v.property },
              :value_0    => lambda { |v| v.property_value.gsub(/.*\:/){""} },
              :value_1    => lambda { |v| v.property_value.gsub(/.*\:/){""}  },
              :example_0  => lambda { |v| v.examples.map(&:name).join(", ") },
              :example_1  => lambda { |v| v.examples.map(&:name).join(", ") }
          }
        end
      end

    end
  end
end