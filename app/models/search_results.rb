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
      ResultMapper.new(self.result_groups).to_result_families
    end

    Rails.logger.debug "DEBUG: Inspecting #{@results.inspect}"
    # TODO: paginate also for children!!!
    # Suggestion: flatten results, do the pagination, re-create results with the result of pagination
    total_rows = 0
    @results.each do |result|
      if result.children.any?
        result.children.each do |child|
          total_rows +=1
        end
      end
    end
    #Rails.logger.debug "Step 2 => #{self.class} - Results size:\n#{total_rows}"
    #@results.paginate(:page => @offset, :per_page => DEFAULT_PER_PAGE, :total_entries => total_rows)
    @results.paginate(:page => @offset, :per_page => DEFAULT_PER_PAGE)
  end

  private

  def ensure_result_groups!
    Rails.logger.debug "Step 2 => #{self.class} - Perform the search"
    return true unless self.result_groups.nil?
    return true unless self.query.present? || self.parent_ids.present?
    self.result_groups = build_result_groups(*parent_and_child_lings_property_ids)
  end

  def parent_and_child_lings_property_ids
    ids = [self.parent_ids, self.child_ids].compact

    return ids if ids.any?
    #Rails.logger.debug "Step 3 => #{self.class}"
    filter_lings_property_ids_from_query
  end

  def build_result_groups(parent_ids, child_ids = nil)
    ResultMapper.build_result_groups(parent_ids, child_ids, included_columns)
  end

  def filter_lings_property_ids_from_query
    SearchFilterBuilder.new(query_adapter).filtered_parent_and_child_ids
  end

  def query_adapter
    @query_adapter ||= QueryAdapter.new(self.group, self.query)
  end

end