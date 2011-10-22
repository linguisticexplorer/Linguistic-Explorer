module SearchResults

  class Filter
    attr_reader :filter, :query, :depth_0_vals, :depth_1_vals

    ERRORS = [
      NO_DEPTH_1_RESULT = [-1],
      RESULT_TOO_BIG = [-2]
    ]

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

    def any_error?(result)
      ERRORS.each { |error| return true if error==result }
      return false
    end

    def is_depth_0?(depth)
      return depth.to_i==0
    end

  end
end