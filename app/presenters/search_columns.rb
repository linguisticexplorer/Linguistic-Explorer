module SearchColumns
  PARENT_COLUMNS = [
    :ling_0, :property_0, :value_0, :example_0
  ]

  CHILD_COLUMNS = [
    :ling_1, :property_1, :value_1, :example_1
  ]

  CROSS_COLUMNS = [
      :cross_property, :cross_value, :count
  ]

  COMPARE_PARENT_COLUMNS = [
    :compare_property, :common_values
  ]

  COMPARE_CHILD_COLUMNS = [
    :compare_property, :ling_value
  ]

  COMPARE_COLUMNS = COMPARE_PARENT_COLUMNS | COMPARE_CHILD_COLUMNS

  COLUMNS = PARENT_COLUMNS + CHILD_COLUMNS

  HEADERS = {
    :ling_0           => lambda { |g| g.ling0_name },
    :property_0       => lambda { |g| "#{g.ling0_name} #{g.property_name.pluralize.titleize}" },
    :value_0          => lambda { |g| "#{g.ling0_name} Values" },
    :example_0        => lambda { |g| "#{g.ling0_name} Examples" },
    :ling_1           => lambda { |g| g.ling1_name },
    :property_1       => lambda { |g| "#{g.ling1_name} #{g.property_name.pluralize.titleize}" },
    :value_1          => lambda { |g| "#{g.ling1_name} Values" },
    :example_1        => lambda { |g| "#{g.ling1_name} Examples" },
    # Cross Search
    :count            => lambda { |g| "Count"},
    :cross_property   => lambda { |g| "Property Name"},
    :cross_value      => lambda { |g| "Property Value" },
    # Compare Search
    :compare_property => lambda { |g| "Property Name" },
    :common_values    => lambda { |g| "Common Value"},
    :ling_value       => lambda { |v| "#{v.ling.name} Value"}
  }

  def columns_to_include
    @columns_to_include ||= @search.included_columns
  end

  def result_headers
    header_keys = columns_to_include
    header_keys -= child_columns unless @search.group.has_depth?
    header_keys.map{ |k| HEADERS[k] }
  end

  def result_headers_lings_cross
    header_keys = cross_columns
    header_keys.map{ |k| HEADERS[k] }
  end

  def common_compare_columns
    COMPARE_PARENT_COLUMNS.map {|k| HEADERS[k]}
  end

  def diff_compare_columns
    COMPARE_CHILD_COLUMNS.map {|k| HEADERS[k]}
  end

  def result_rows
    @result_rows ||= row_methods.map { |k| row_methods[k] }
  end

  def parent_columns
    @parent_columns ||= columns_to_include & PARENT_COLUMNS
  end

  def child_columns
    @child_columns ||= columns_to_include & CHILD_COLUMNS
  end

  def cross_columns
    if @search.depth_of_cross_search == Depth::PARENT
      [PARENT_COLUMNS.first]
    else
      [CHILD_COLUMNS.first]
    end
  end

end
