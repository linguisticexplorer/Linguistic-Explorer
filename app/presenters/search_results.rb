module SearchResults
  include Enumerable
  include Layout

  def each
    results.each { |r| yield r }
  end

  def results
    filter = filter_vals

    selected_lings_prop_ids = (filter.depth_0_vals + filter.depth_1_vals).map(&:id)
    depth_0_ids = filter.depth_0_vals.map(&:id)
    depth_1_ids = filter.depth_1_vals.map(&:id)

    parents = LingsProperty.with_id(depth_0_ids).includes([:ling, :property]).
      joins(:ling).
      order("lings.parent_id, lings.name")

    if @group.has_depth?
      children = LingsProperty.with_id(depth_1_ids).includes([:ling, :property]).
        joins(:ling).
        order("lings.parent_id, lings.name")

      parents.map { |parent|
        children.select { |child| child.ling.parent_id == parent.ling_id }.map { |child|
          ResultSet.new(parent, child)
        }
      }.flatten
    else
      parents.map { |parent| ResultSet.new(parent) }
    end
  end

  class ResultSet
    def initialize(parent, child = nil)
      @parent, @child = parent, child
    end

    def parent(method)
      @parent.send(method)
    end

    def child(method)
      @child.send(method) if @child
    end
    
    def parent_examples
      @parent.examples.map(&:name).join(", ")
    end

    def child_examples
      @child.examples.map(&:name).join(", ")
    end

  end

  private

  def filter_vals
    # Filters return depth_0_vals and depth_1_vals

    filter = filter_by_any_selected_lings_and_props

    filter = filter_by_keywords           filter, :ling

    filter = filter_by_keywords           filter, :property

    filter = filter_by_val_params         filter

    filter = filter_by_depth_intersection filter

    filter = filter_by_all_conditions     filter, :property

    filter = filter_by_all_conditions     filter, :lings_property

    filter
  end

  def params
    @params_adapter ||= ParamsAdapter.new(@group, @params)
  end

  def filter_by_any_selected_lings_and_props
    SelectAnyFilter.new(params)
  end

  def filter_by_keywords(filter, strategy)
    KeywordFilter.new(filter, params) do |f|
      f.strategy = strategy
    end
  end

  def filter_by_val_params(filter)
    SelectValuePairsFilter.new(filter, params)
  end

  def filter_by_depth_intersection(filter)
    IntersectionFilter.new(filter, params)
  end

  def filter_by_all_conditions(filter, strategy)
    SelectAllFilter.new(filter, params) do |f|
      f.strategy = strategy
    end
  end

end