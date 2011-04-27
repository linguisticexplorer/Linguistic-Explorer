module SearchResults

  class ResultMapper

    attr_reader :result_rows

    def initialize(result_rows)
      @result_rows = result_rows
    end

    def to_results
      @to_results ||= begin
        result_rows.group_by { |row| row[Depth::PARENT] }.map do |parent_id, result_row|
          parent            = parents.detect { |parent| parent.id == parent_id }
          related_children  = children.select { |child| child.parent_ling_id == parent_id }
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
        if child_ids.present?
          LingsProperty.with_id(child_ids).includes([:ling, :property]).joins(:ling).
          order("lings.parent_id, lings.name").to_a
        else
          []
        end
      end
    end

    def parent_ids
      result_rows.map { |row| row[Depth::PARENT]  }.flatten.uniq.compact
    end

    def child_ids
      result_rows.map { |row| row[Depth::CHILD]   }.flatten.uniq.compact
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