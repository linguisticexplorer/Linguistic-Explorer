module SearchResults

  class ResultMapper

    def initialize(parent_ids, child_ids)
      @parent_ids, @child_ids = parent_ids, child_ids
    end

    def to_results
      if @child_ids.any?
        parents.map { |parent|
          related_children = children.select { |child| child.ling.parent_id == parent.ling_id }
          ResultFamily.new(parent, related_children)
        }.flatten
      else
        parents.map { |parent| ResultFamily.new(parent) }
      end
    end

    def parents
      @parents ||= LingsProperty.with_id(@parent_ids).includes([:ling, :property]).
        joins(:ling).
        order("lings.parent_id, lings.name")
    end

    def children
      @children ||= LingsProperty.with_id(@child_ids).includes([:ling, :property]).joins(:ling).
        order("lings.parent_id, lings.name")
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
end