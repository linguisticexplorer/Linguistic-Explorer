class SearchCross

    def initialize(lings_ids)
      @ling_ids = lings_ids
    end

    def filter_lings_row(search)
      search.results.select {|result| are_same_ling_ids?(result.child) }
    end

    def ling_ids
      @ling_ids.collect {|id| id.to_i}
    end

    def are_same_ling_ids?(lings)
      lings.map(&:id).sort == ling_ids.sort
    end

  end