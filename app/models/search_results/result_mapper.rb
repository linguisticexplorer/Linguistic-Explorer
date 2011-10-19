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

      # group parents separately with each related child
      result = {}.tap do |groups|
        parent_filtered_results.each do |parent|
          related_children  = child_filtered_results.select { |child| child.parent_ling_id == parent.ling_id }
          groups[parent.id.to_i] = related_children.map(&:id).map(&:to_i)
        end
      end
      #Rails.logger.debug "DEBUG: Results => #{result.size}"
      return result
    end

    attr_reader :result_groups

    def initialize(result_groups)
      @result_groups = result_groups
    end

    def to_result_families
      @result_families ||= begin
        result_groups.map do |parent_id, child_ids|
          parent            = parents.detect { |parent| parent.id.to_i == parent_id.to_i }
          related_children  = children.select { |child| child_ids.include? child.id }
          ResultFamily.new(parent, related_children)
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
      parent_filtered_results = parent_results.select { |r| r if filter.columns_filter(r, Depth::PARENT) }
      child_filtered_results = child_results.select { |r| r if filter.columns_filter(r, Depth::CHILD) }

      [child_filtered_results, parent_filtered_results]
    end

  end

  class ResultFamily
    attr_reader :parent

    def initialize(parent, children = nil)
      @parent, @children = parent, children
    end

    def children
      @children || []
    end

  end

  class ColumnsFilter

    def initialize(columns)
      #Rails.logger.debug "DEBUG: #{columns}"
      @columns ||= columns
      @selected ||={}
      @test_0 = true
      @test_1 = true
      @columns.each do |col|
        @test_0 &= col.to_s=~/0/
        @test_1 &= col.to_s=~/1/
      end
      #Rails.logger.debug "DEBUG: \n\tTest_0: #{@test_0} \n\tTest_1: #{@test_1}"
    end

    def columns_filter(result, family)
      depth = -1
      #family==0 ? Rails.logger.debug("DEBUG: Parent =>") : Rails.logger.debug("DEBUG: Child =>")
      depth = Depth::PARENT if (@test_0 || !@test_0 && !@test_1) && family==Depth::PARENT
      depth = Depth::CHILD if @test_1 || !@test_0 && !@test_1 && family==Depth::CHILD
      return false if depth == -1
      #return child_columns_filter(result, depth) if family==Depth::CHILD
      return parent_columns_filter(result, depth)
    end

    private

    def parent_columns_filter(result, depth)
      index = []
      @columns.each do |col|
        index << columns_mapping[col].call(result) if col.to_s=~/#{depth}/
      end

      already_written?(index)
    end

    def already_written?(index)
      return false if index.empty?
      @selected[index]= 1 if !@selected[index].nil?
      @selected[index]= 0 if @selected[index].nil?
      #Rails.logger.debug "DEBUG: \n\t#{@selected[index]== 0} =>\n\tIndex:#{index.inspect}" if @selected[index]== 0
      return @selected[index]== 0
    end

    def columns_mapping
      row_methods ||= {
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

    #def child_columns_filter(result, depth)
    #  index = []
    #  @columns.each do |col|
    #    next if col.to_s=~/value/
    #    index << columns_mapping[col].call(result) if col.to_s=~/#{depth}/
    #  end
    #
    #  already_written?(index)
    #end
  end
end