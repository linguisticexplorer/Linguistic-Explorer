module SearchColumns
  PARENT_COLUMNS = [
    :ling_0, :property_0, :value_0, :example_0
  ]

  CHILD_COLUMNS = [
    :ling_1, :property_1, :value_1, :example_1
  ]

  COLUMNS = PARENT_COLUMNS + CHILD_COLUMNS

  HEADERS = {
    :ling_0     => lambda { |g| g.ling0_name },
    :property_0 => lambda { |g| "#{g.ling0_name} #{g.property_name.pluralize.titleize}" },
    :value_0    => lambda { |g| "#{g.ling0_name} Values" },
    :example_0  => lambda { |g| "#{g.ling0_name} Examples" },
    :ling_1     => lambda { |g| g.ling1_name },
    :property_1 => lambda { |g| "#{g.ling1_name} #{g.property_name.pluralize.titleize}" },
    :value_1    => lambda { |g| "#{g.ling1_name} Values" },
    :example_1  => lambda { |g| "#{g.ling1_name} Examples" }
  }

  def columns_to_include
    @columns_to_include ||= @search.included_columns
  end

  def result_headers
    header_keys = columns_to_include
    header_keys -= child_columns unless @search.group.has_depth?
    header_keys.map{ |k| HEADERS[k] }
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

end
