module SearchColumns
  PARENT_COLUMNS = [
      :ling_0_id, :ling_0, :property_0, :value_0, :example_0
  ]

  CHILD_COLUMNS = [
      :ling_1_id, :ling_1, :property_1, :value_1, :example_1
  ]

  CROSS_COLUMNS = [
      :cross_property, :cross_value, :count
  ]

  COMPARE_COMMON_COLUMNS = [
      :compare_property, :common_values
  ]

  COMPARE_DIFF_COLUMNS = [
      :compare_property, :ling_value
  ]

  COLUMNS = PARENT_COLUMNS + CHILD_COLUMNS

  HEADERS = {
      :ling_0_id        => lambda { |g| "#{g.ling0_name} ID" },
      :ling_0           => lambda { |g| g.ling0_name },
      :property_0       => lambda { |g| "#{g.ling0_name} #{g.property_name.pluralize.titleize}" },
      :value_0          => lambda { |g| "#{g.ling0_name} Values" },
      :example_0        => lambda { |g| "#{g.ling0_name} Examples" },
      :ling_1_id        => lambda { |g| "#{g.ling1_name} ID" },
      :ling_1           => lambda { |g| g.ling1_name },
      :property_1       => lambda { |g| "#{g.ling1_name} #{g.property_name.pluralize.titleize}" },
      :value_1          => lambda { |g| "#{g.ling1_name} Values" },
      :example_1        => lambda { |g| "#{g.ling1_name} Examples" },
      # Cross & Implication Search
      :count            => lambda { |g| "Count"},
      :cross_property   => lambda { |g| "#{g.property_name.titleize} Name"},
      :cross_value      => lambda { |g| "#{g.property_name.titleize} Value" },
      # Compare Search
      :compare_property => lambda { |g| "#{g.property_name.titleize} Name" },
      :common_values    => lambda { |g| "Common Value"},
      :ling_value       => lambda { |v| v ? "#{v.name} Value" : ""},
  }

  def columns_to_include
    @columns_to_include ||= @search.included_columns
  end

  def result_headers(entry=nil)
    header_keys ||= result_headers_cross(entry) if @search.cross? || @search.implication?
    header_keys ||= result_headers_compare(entry) if @search.compare?
    if @search.default?
      header_keys ||= columns_to_include
      header_keys -= child_columns unless @search.group.has_depth?
    end
    header_keys.map{ |k| { :key => k, :value => HEADERS[k] } }
  end

  def result_headers_lings_cross
    header_keys = cross_lings_columns
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

  def cross_lings_columns
    @search.implication? ? [PARENT_COLUMNS.first] :
    @search.depth_of_cross_search == Depth::PARENT ? [PARENT_COLUMNS.first] : [CHILD_COLUMNS.first]
  end

  private

  # This method will scale the number of columns based of Property choosen
  def scale_cross_columns
    search_results = @search.results
    if search_results.empty?
      CROSS_COLUMNS
    else
      name, value, count = CROSS_COLUMNS
      props = search_results.first.parent
      [].tap do |columns_to_show|
        props.each {|p| columns_to_show << [name, value] }
        columns_to_show << count
      end.flatten
    end
  end

  def result_headers_compare(entry)
    # If it is one LingsProperty object then is a Common Property
    entry.size>1 ? COMPARE_DIFF_COLUMNS : COMPARE_COMMON_COLUMNS
  end

  def result_headers_cross(entry=nil)
    scale_cross_columns if entry.nil?
  end

end
