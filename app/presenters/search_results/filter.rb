module SearchResults

  class Filter
    attr_reader :filter, :depth_0_vals, :depth_1_vals

    def initialize(filter, params = {})
      @filter   = filter
      @params   = params
    end

    def vals_at(depth)
      send("depth_#{depth}_vals")
    end

    def method_missing(method_sym, *arguments, &block)
      if @filter.respond_to?(method_sym)
        @filter.send(method_sym, *arguments, &block)
      else
        super
      end
    end

  end
end