module SearchResults

  class Filter
    attr_reader :filter, :query, :depth_0_vals, :depth_1_vals

    def initialize(filter, query)
      @filter   = filter
      @query   = query

      Rails.logger.info "_______#{self.class.name}_________"
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

    def depth_0_ids
      depth_0_vals.map(&:id)
    end

    def depth_1_ids
      depth_1_vals.map(&:id)
    end

  end
end