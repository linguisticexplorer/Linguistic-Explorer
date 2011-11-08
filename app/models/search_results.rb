module SearchResults
  include Enumerable
  include Comparisons

  # To add paginate method in Array class
  # https://github.com/mislav/will_paginate/wiki/Backwards-incompatibility
  require 'will_paginate/array'

  delegate :included_columns, :to => :query_adapter

  def each
    results.each { |r| yield r }
  end

  def results
    @results ||= begin
      ensure_result_groups!
      Rails.logger.debug "Step 4 => #{self.class} - Rendering"
      ResultMapperBuilder.new(self.result_groups).to_flatten_results
    end
    #Rails.logger.debug "Step 2 => #{self.class} - Results size:#{@results.inspect}"
    @results.paginate(:page => @offset, :per_page => DEFAULT_PER_PAGE)
  end

  def default?
    self.result_groups[:type] == :default
  end

  def cross?
    self.result_groups[:type] == :cross
  end

  private

  def ensure_result_groups!
    Rails.logger.debug "Step 2 => #{self.class} - Perform the search"
    return true unless self.result_groups.nil? || self.query.present?
    self.result_groups ||= build_result_groups(filter_lings_property_ids_from_query)
  end

  def build_result_groups(result_adapter)
    ResultMapperBuilder.build_result_groups(result_adapter)
  end

  def filter_lings_property_ids_from_query
    SearchFilterBuilder.new(query_adapter).perform_search
  end

  def query_adapter
    @query_adapter ||= QueryAdapter.new(self.group, self.query)
  end

end