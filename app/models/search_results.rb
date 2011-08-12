module SearchResults
  include Enumerable
  include Comparisons

  delegate :included_columns, :to => :query_adapter

  def each
    results.each { |r| yield r }
  end

  def results
    @results ||= begin
      ensure_result_groups!
      ResultMapper.new(self.result_groups).to_result_families
    end
  end

  private

  def ensure_result_groups!
    Rails.logger.debug "Step 2 => #{self.class}"
    return true unless self.result_groups.nil?
    return true unless self.query.present? || self.parent_ids.present?
    self.result_groups = build_result_groups(*parent_and_child_lings_property_ids)
  end

  def parent_and_child_lings_property_ids
    ids = [self.parent_ids, self.child_ids].compact

    return ids if ids.any?
    Rails.logger.debug "Step 3 => #{self.class}"
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