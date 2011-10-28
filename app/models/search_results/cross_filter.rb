module SearchResults

  class CrossFilter < Filter

    def initialize(filter, query)
      super

      @depth_0_vals, @depth_1_vals = filter.depth_0_vals, filter.depth_1_vals
    end


  end

end