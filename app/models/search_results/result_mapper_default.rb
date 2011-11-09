module SearchResults

  class ResultMapperDefault

    attr_reader :result_groups

    def initialize(results)
      @result_groups = results
    end

    def to_flatten_results
      @flatten_results ||= [].tap do |entry|
        result_groups.each do |parent_id, child_ids|
          parent           = parents.detect { |parent| parent.id.to_i == parent_id.to_i }
          related_children = children.select { |child| child_ids.include? child.id.to_i }
          if related_children.any?
            related_children.each { |child| entry << ResultEntry.new(parent, child) }
          else
            entry << ResultEntry.new(parent)
          end
        end
      end
    end

    def parents
      @parents ||= LingsProperty.with_id(parent_ids).includes([:ling, :property, :examples, :examples_lings_properties]).
          joins(:ling).order("lings.parent_id, lings.name").to_a
    end

    def children
      @children ||= begin
        if all_child_ids.present?
          LingsProperty.with_id(all_child_ids).includes([:ling, :property, :examples, :examples_lings_properties]).joins(:ling).
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

  class ResultEntry
    attr_reader :parent

    def initialize(parent, child=nil)
      @parent, @child = parent, child
    end

    def child
      @child
    end

  end
end