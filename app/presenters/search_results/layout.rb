module SearchResults
  module Layout
    COLUMNS = [ :ling_0, :ling_1, :ling_type, :prop, :value, :parent ]

    HEADERS = {
      :ling_0     => lambda { |g| g.ling0_name },
      :ling_1     => lambda { |g| g.ling1_name },
      :ling_type  => lambda { |g| "Ling Type" },
      :prop       => lambda { |g| g.property_name.pluralize.titleize },
      :value      => lambda { |g| g.lings_property_name.pluralize.titleize },
      :parent     => lambda { |g| "Parent" }
    }

    ROWS = {
      :ling_0     => lambda { |g, r| r.ling_name_for_depth Depth::PARENT  },
      :ling_1     => lambda { |g, r| r.ling_name_for_depth Depth::CHILD   },
      :ling_type  => lambda { |g, r| g.ling_name_for_depth(r.ling.depth) },
      :prop       => lambda { |g, r| r.prop_name },
      :value      => lambda { |g, r| r.value },
      :parent     => lambda { |g, r| r.parent_name }
    }


    def result_headers
      (COLUMNS - excluded_columns).map{ |k| HEADERS[k] }
    end

    def result_rows
      @result_rows ||= (COLUMNS - excluded_columns).map { |k| ROWS[k] }
    end

    def excluded_columns
      # {"ling_0"=>"1", "ling_1"=>"1", "prop"=>"1", "value"=>"1"}
      included = params[:include].symbolize_keys.keys
      included << :ling_type if included.include?(:ling_0) || included.include?(:ling_0)
      included << :parent if included.include?(:ling_1)
      COLUMNS - included
    end

  end
end