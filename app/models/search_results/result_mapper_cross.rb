module SearchResults

  class ResultMapperCross
    attr_reader :result_groups

    def initialize(results)
      @result_groups = results
    end

    def to_flatten_results
      @flatten_results ||= [].tap do |entry|
        result_groups.each do |parent_ids, children_ids|
          parent           = parents.select {|parent| parent.map(&:id).sort == parent_ids.sort }.flatten
          related_children = children.select {|child| child.map(&:ling_id).sort == children_ids.sort }.flatten
          entry << ResultEntry.new(parent, related_children)
        end
      end
    end

    def parents
      @parents ||= [].tap do |parent|
        parent_ids.each do |parent_id|
          parent << LingsProperty.with_id(parent_id).joins(:property).includes([:property]).order("properties.name")
        end
      end
    end

    def children
      @children ||= [].tap do |child|
        all_child_ids.each do |children_ids|
          lings = children_by_lings(children_ids)
          child << lings if lings.any?
        end
      end
    end

    def all_child_ids
      result_groups.values
    end

    def parent_ids
      result_groups.keys
    end

    private

    def children_by_lings(children_ids)
      ling_props = LingsProperty.with_ling_id(children_ids).joins(:ling, :property).includes([:ling, :property]).order("lings.name").to_a.group_by {|lp| lp.ling }
      ling_props.keys.map {|ling| ling_props[ling].first}
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