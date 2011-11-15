module SearchResults

  class ResultMapperDefault < ResultMapper

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

  end

end