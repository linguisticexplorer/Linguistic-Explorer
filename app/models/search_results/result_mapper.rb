module SearchResults

  class ResultMapper

    def self.build_result_groups(parent_ids, child_ids = [], columns)
      # Eager-loading for a fast response on a big set of data
      parent_results  = LingsProperty.select_ids.with_id(parent_ids).
          includes(:property, :examples, :examples_lings_properties, :ling)

      child_results   = LingsProperty.with_id(child_ids).includes([:ling]).
          joins(:ling).order("lings.parent_id, lings.name").
          includes(:property, :examples, :examples_lings_properties)

      child_filtered_results, parent_filtered_results = filter_results_by_columns(parent_results, child_results, columns)

      #group parents separately with each related child
      {}.tap do |groups|
        parent_filtered_results.each do |parent|
          related_children  = child_filtered_results.select { |child| child.parent_ling_id == parent.ling_id }
          groups[parent.id.to_i] = related_children.map(&:id).map(&:to_i)
        end
      end
    end

    attr_reader :result_groups

    def initialize(result_groups)
      @result_groups = result_groups
    end

    def to_flatten_results
      @flatten_results ||= [].tap do |entry|
        result_groups.each do |parent_id, child_ids|
          parent           = parents.detect { |parent| parent.id.to_i == parent_id.to_i }
          related_children  = children.select { |child| child_ids.include? child.id }
          if related_children.any?
            related_children.each { |child| entry << ResultEntry.new(parent, child) }
          else
            entry << ResultEntry.new(parent)
          end
        end
      end
    end

    def parents
      @parents ||= LingsProperty.with_id(parent_ids).includes([:ling, :property]).
          joins(:ling).
          order("lings.parent_id, lings.name").to_a
    end

    def children
      @children ||= begin
        if all_child_ids.present?
          LingsProperty.with_id(all_child_ids).includes([:ling, :property]).joins(:ling).
              order("lings.parent_id, lings.name").to_a
        else
          []
        end
      end
    end

    def all_child_ids
      result_groups.values.flatten.uniq.compact
    end

    def parent_ids
      result_groups.keys
    end

    def self.filter_results_by_columns(parent_results, child_results, columns)
      filter = ColumnsFilter.new(columns)
      parent_filtered_results = parent_results.select { |r| r if filter.filter_result_by_column?(r, Depth::PARENT) }
      child_filtered_results = child_results.select { |r| r if filter.filter_result_by_column?(r, Depth::CHILD) }

      [child_filtered_results, parent_filtered_results]
    end

  end

  class ResultEntry
    attr_reader :parent

    def initialize(parent, child=nil)
      @parent, @child = parent, child
    end

    def child
      @child
    end

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