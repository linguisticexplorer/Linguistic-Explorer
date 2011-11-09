module SearchResults

  class ResultMapperBuilder

    attr_reader :result
    attr_accessor :strategy

    def initialize(result_adapter)
      @result = result_adapter
    end

    def to_flatten_results
      @flatten_results ||= strategy_class.new(sanitize_result).to_flatten_results
    end

    private

    def sanitize_result
      @result.select {|k,v| !/type/.match(k.to_s)}
    end

    def strategy
      @strategy ||= @result["type"] || :default
    end

    def strategy_class
      "SearchResults::ResultMapper#{strategy.to_s.camelize}".constantize
    end

    def self.build_result_groups(result_adapter)
      result = case result_adapter.type
        when :cross
          cross_builder(result_adapter).build_result_groups
        else
          default_builder(result_adapter).build_result_groups
               end
      result["type"] = result_adapter.type
      result
    end


    def self.cross_builder(result)
      CrossGroupsBuilder.new(result)
    end

    def self.default_builder(result)
      DefaultGroupsBuilder.new(result)
    end

    class GroupsBuilder

      attr_reader :result

      def initialize(result)
        @result = result
      end

      def parent_ids
        @result.parent
      end

      def child_ids
        @result.child
      end

      def columns
        @result.columns
      end

      def empty_result
        {}
      end

      def is_parent?(depth)
        depth == Depth::PARENT
      end

      def klass
        /Default|Cross/.match(self.class.name)[0].constantize
      end
    end

    class CrossGroupsBuilder < GroupsBuilder
      def build_result_groups

        vals = LingsProperty.with_id(vals_for_cross)
        vals_by_prop_ids = vals_by_property_id(vals)

        prop_values = [].tap do |p|
          vals_by_prop_ids.keys.each do |prop_id|
            p << vals_by_prop_ids[prop_id].map(&:property_value).uniq
          end
        end

        first_prop = prop_values.first
        rest_props = prop_values.drop(1)

        combinations = first_prop.product(*rest_props)

        combinations.each do |c|
          c.map! do |prop_value|
            LingsProperty.find_by_property_value(prop_value)
          end
        end

        {}.tap do |groups|
          combinations.map do |comb_parents|
            comb_parent_ids = comb_parents.map {|p| p.id.to_i}
            groups[comb_parent_ids] = lings_ids_in_combination(vals, comb_parents)
          end
        end
      end

      private

      def depth_for_cross
        @result.depth_for_cross
      end

      def vals_for_cross
        is_parent?(depth_for_cross) ? parent_ids : child_ids
      end

      def vals_by_property_id(vals)
        vals.group_by { |v| v.property_id }
      end

      def vals_by_ling_id(vals)
        vals.group_by { |v| v.ling_id }
      end

      def lings_ids_in_combination(vals, combination)
        lings_ids = vals_by_ling_id(vals)

        lings_ids.select do |ling|
          combination.map {|lp| lp.property_value.to_s}.
              all? { |value| ling_with_combination?(lings_ids[ling], value) }
        end.keys
      end

      def ling_with_combination?(ling_props, value)
        ling_props.select { |lp| lp.property_value == value}.any?
      end
    end

    class DefaultGroupsBuilder < GroupsBuilder
      def build_result_groups

        # Eager-loading for a fast response on a big set of data
        parent_results  = LingsProperty.select_ids.with_id(parent_ids).
            includes(:property, :examples, :examples_lings_properties, :ling)

        child_results   = LingsProperty.with_id(child_ids).includes([:ling]).
            joins(:ling).order("lings.parent_id, lings.name").
            includes(:property, :examples, :examples_lings_properties)

        parent_filtered_results, child_filtered_results = filter_results_by_columns(parent_results, child_results)

        #group parents separately with each related child
        {}.tap do |groups|
          parent_filtered_results.each do |parent|
            related_children  = child_filtered_results.select { |child| child.parent_ling_id == parent.ling_id }
            groups[parent.id.to_i] = related_children.map(&:id).map(&:to_i)
          end
        end
      end

      private

      def filter_results_by_columns(parent_results, child_results)
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
          index = []
          @columns.each do |col|
            index << result_mapping(col, result) if col.to_s=~/#{depth}/
          end
          already_written?(index)
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
              :ling_0     => lambda { |v| v.ling },
              :ling_1     => lambda { |v| v.ling },
              :property_0 => lambda { |v| v.property },
              :property_1 => lambda { |v| v.property },
              :value_0    => lambda { |v| v.property_value.gsub!(/.*\:/){""} },
              :value_1    => lambda { |v| v.property_value.gsub!(/.*\:/){""}  },
              :example_0  => lambda { |v| v.examples.map(&:name).join(", ") },
              :example_1  => lambda { |v| v.examples.map(&:name).join(", ") }
          }
        end
      end

    end

  end

end