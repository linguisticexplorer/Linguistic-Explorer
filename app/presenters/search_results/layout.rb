module SearchResults
  module Layout

    HEADERS = {
      :ling_0     => lambda { |g| g.ling0_name },
      :prop_0     => lambda { |g| "#{g.ling0_name} #{g.property_name.pluralize.titleize}" },
      :val_0      => lambda { |g| "#{g.ling0_name} Values" },
      :exmp_0     => lambda { |g| "#{g.ling0_name} Examples" },
      :ling_1     => lambda { |g| g.ling1_name },
      :prop_1     => lambda { |g| "#{g.ling1_name} #{g.property_name.pluralize.titleize}" },
      :val_1      => lambda { |g| "#{g.ling1_name} Values" },
      :exmp_1     => lambda { |g| "#{g.ling1_name} Examples" }
    }

    COLUMNS = HEADERS.keys

    ROWS = {
      :ling_0     => lambda { |g, r| r.parent(:ling).name },
      :ling_1     => lambda { |g, r| r.child(:ling).name },
      :prop_0     => lambda { |g, r| r.parent(:property).name },
      :prop_1     => lambda { |g, r| r.child(:property).name },
      :val_0      => lambda { |g, r| r.parent(:value)  },
      :val_1      => lambda { |g, r| r.child(:value)  },
      :exmp_0     => lambda { |g, r| r.parent_examples },
      :exmp_1     => lambda { |g, r| r.child_examples }
    }

    def result_headers
      (COLUMNS - excluded_columns).map{ |k| HEADERS[k] }
    end

    def result_rows
      @result_rows ||= (COLUMNS - excluded_columns).map { |k| ROWS[k] }
    end

    def excluded_columns
      # {"ling_0"=>"1", "ling_1"=>"1", "prop"=>"1", "value"=>"1"}
      COLUMNS - params[:include].symbolize_keys.keys
    end

  end
end