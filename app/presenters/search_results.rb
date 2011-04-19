module SearchResults
  include Enumerable

  delegate :included_columns, :to => :query_adapter

  def each
    results.each { |r| yield r }
  end

  def results
    @results ||= begin
      if self.parent_ids.blank?
        filter = filter_vals

        selected_lings_prop_ids = (filter.depth_0_vals + filter.depth_1_vals).map(&:id)
        self.parent_ids = filter.depth_0_vals.map(&:id)
        self.child_ids  = filter.depth_1_vals.map(&:id)
      end
      parents, children = nil

      Search.benchmark("____________Select parents") do
        parents = LingsProperty.with_id(self.parent_ids).includes([:ling, :property]).
          joins(:ling).
          order("lings.parent_id, lings.name")
      end

      if @group.has_depth?

      Search.benchmark("______________Select children") do
        children = LingsProperty.with_id(self.child_ids).includes([:ling, :property]).joins(:ling).
          order("lings.parent_id, lings.name")
      end

      Search.benchmark("_____________Build result sets") do
        parents.map { |parent|
          related_children = children.select { |child| child.ling.parent_id == parent.ling_id }
          ResultFamily.new(parent, related_children)
        }.flatten
      end
      else
        parents.map { |parent| ResultFamily.new(parent) }
      end
    end
  end

  private

  def filter_vals
    # Filters return depth_0_vals and depth_1_vals

    filter = filter_by_any_selected_lings_and_props

    filter = filter_by_keywords           filter, :ling

    filter = filter_by_keywords           filter, :property

    filter = filter_by_keywords           filter, :example

    filter = filter_by_val_query_params   filter

    filter = filter_by_depth_intersection filter

    filter = filter_by_all_conditions     filter, :property

    filter = filter_by_all_conditions     filter, :lings_property

    filter
  end

  def query_adapter
    @query_adapter ||= QueryAdapter.new(self.group, self.query)
  end

  def filter_by_any_selected_lings_and_props
    SelectAnyFilter.new(query_adapter)
  end

  def filter_by_keywords(filter, strategy)
    KeywordFilter.new(filter, query_adapter) do |f|
      f.strategy = strategy
    end
  end

  def filter_by_val_query_params(filter)
    SelectValuePairsFilter.new(filter, query_adapter)
  end

  def filter_by_depth_intersection(filter)
    IntersectionFilter.new(filter, query_adapter)
  end

  def filter_by_all_conditions(filter, strategy)
    SelectAllFilter.new(filter, query_adapter) do |f|
      f.strategy = strategy
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

  # class ResultSet
  #   def initialize(parent, child = nil)
  #     @parent, @child = parent, child
  #   end
  # 
  #   def parent(method)
  #     @parent.send(method)
  #   end
  # 
  #   def child(method)
  #     @child.send(method) if @child
  #   end
  # 
  #   def parent_examples
  #     @parent.examples.map(&:name).join(", ")
  #   end
  # 
  #   def child_examples
  #     @child.examples.map(&:name).join(", ")
  #   end
  # 
  # end

end