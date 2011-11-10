class SearchCross

    def initialize(parent_ids)
      @parent_ids = parent_ids
    end

    def filter_lings_row(search)
      search.results.select {|result| are_parent_ids?(result.parent) }
    end

    def parent_ids
      @parent_ids.collect {|id| id.to_i}
    end

    def are_parent_ids?(parent)
      parent.map(&:id) == parent_ids
    end

  end