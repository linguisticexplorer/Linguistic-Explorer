module SearchResultsHelper
  include ActionView

  HEADERS = {
    :ling_0     => lambda { |g| g.ling0_name },
    :ling_1     => lambda { |g| g.ling1_name },
    :property_0 => lambda { |g| "#{g.ling0_name} #{g.property_name.pluralize.titleize}" },
    :property_1 => lambda { |g| "#{g.ling1_name} #{g.property_name.pluralize.titleize}" },
    :value_0    => lambda { |g| "#{g.ling0_name} Values" },
    :value_1    => lambda { |g| "#{g.ling1_name} Values" },
    :example_0  => lambda { |g| "#{g.ling0_name} Examples" },
    :example_1  => lambda { |g| "#{g.ling1_name} Examples" }
  }

  COLUMNS = HEADERS.keys

  def result_headers(included_columns)
    (COLUMNS - excluded_columns(included_columns)).map{ |k| HEADERS[k] }
  end

  def result_rows(included_columns)
    @result_rows ||= (COLUMNS - excluded_columns(included_columns)).map { |col| row_methods[col] }
  end

  def excluded_columns(included_columns)
    # {"ling_0"=>"1", "ling_1"=>"1", "prop"=>"1", "value"=>"1"}
    COLUMNS - included_columns
  end
  
  def row_methods
    @row_methods ||= {
      :ling_0     => lambda { |r|
        link_to r.parent(:ling).name, [current_group, r.parent(:ling)]
      },
      :ling_1     => lambda { |r|
        link_to r.child(:ling).name, [current_group, r.child(:ling)]
      },
      :property_0 => lambda { |r|
        link_to r.parent(:property).name, [current_group, r.parent(:ling) ]
      },
      :property_1 => lambda { |r|
        link_to r.child(:property).name, [current_group, r.child(:ling) ]
      },
      :value_0    => lambda { |r| r.parent(:value)  },
      :value_1    => lambda { |r| r.child(:value)  },
      :example_0  => lambda { |r| r.parent_examples },
      :example_1  => lambda { |r| r.child_examples }
    }
  end

  def search_result_attributes(result)
    {}.tap do |attrs|
      attrs[:class] = "row"
      ["parent", "child"].each do |depth|
        [:ling, :property].each do |method|
          attrs["data-#{depth}-#{method}"] = result.send(depth, method).try(:id)
        end
        attrs["data-#{depth}-value"] = result.send(depth, :id)
      end
    end
  end


end