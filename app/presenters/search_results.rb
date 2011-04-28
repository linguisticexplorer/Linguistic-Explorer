module SearchResults
  include Enumerable

  delegate :included_columns, :to => :query_adapter

  def each
    results.each { |r| yield r }
  end

  def results
    @results ||= begin
      ensure_result_rows!
      ResultMapper.new(self.result_rows).to_results
    end
  end

  private

  def ensure_result_rows!
    return true unless self.result_rows.blank?
    return true unless self.query.present? || self.parent_ids.present?
    self.result_rows = build_result_rows(*parent_and_child_lings_property_ids)
  end

  def parent_and_child_lings_property_ids
    ids = [self.parent_ids, self.child_ids].compact

    return ids if ids.any?

    filter_lings_property_ids_from_query
  end

  def build_result_rows(parent_ids, child_ids = nil)
    if self.group.has_depth? && child_ids.present?
      parent_results = LingsProperty.select_ids.with_id(parent_ids)
      child_results = LingsProperty.with_id(child_ids).includes([:ling]).
        joins(:ling).order("lings.parent_id, lings.name")
      child_results.map do |child|
        parent = parent_results.detect { |parent| child.parent_ling_id == parent.ling_id }
        [parent.id, child.id]
      end
    else
      parent_ids.map { |id| [id] }
    end
  end

  def filter_lings_property_ids_from_query
    SearchFilterBuilder.new(query_adapter).filtered_ids
  end

  def query_adapter
    @query_adapter ||= QueryAdapter.new(self.group, self.query)
  end

end