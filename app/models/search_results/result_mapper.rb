module SearchResults

  class ResultMapper

    def self.build_result_groups(parent_ids, child_ids = [])
      parent_results  = LingsProperty.select_ids.with_id(parent_ids)
      child_results   = LingsProperty.with_id(child_ids).includes([:ling]).
        joins(:ling).order("lings.parent_id, lings.name")

      # group parents separately with each related child
      {}.tap do |groups|
        parent_results.each do |parent|
          related_children  = child_results.select { |child| child.parent_ling_id == parent.ling_id }
          groups[parent.id.to_i] = related_children.map(&:id).map(&:to_i)
        end
      end
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