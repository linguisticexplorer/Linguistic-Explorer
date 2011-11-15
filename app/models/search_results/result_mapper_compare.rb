module SearchResults

  class ResultMapperCompare < ResultMapper

    def to_flatten_results
      @flatten_results ||= [].tap do |entry|
        result_groups.each do |parent_id, children_ids|
          parent            = parents.select {|parent| parent.id.to_i == parent_id.to_i}
          related_children  = children.select {|child| child.map(&:id).sort == children_ids.sort }.flatten
          entry << ResultEntry.new(parent, related_children)
        end
      end
    end

    def parents
      @parents ||= LingsProperty.with_id(parent_ids).joins(:property).
          includes([:property]).order("properties.name")
    end

    def children
      @children ||= [].tap do |child|
        all_child_ids.each do |children_ids|
          child << LingsProperty.with_id(children_ids).joins(:ling, :property).includes([:ling, :property])
        end
      end
    end

  end
end