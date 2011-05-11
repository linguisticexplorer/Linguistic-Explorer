module SearchResults
  include Enumerable

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

  def result_rows=(result_rows)
    self.result_groups = result_rows.group_by { |row| row[0] }
    self.result_groups.values.map! { |row| row.map! { |r| r[1] }.compact! }
  end

  def result_rows
    [].tap do |rows|
      self.result_groups.each do |parent_id, child_ids|
        if child_ids.present?
          child_ids.each do |child_id|
            rows << [parent_id, child_id]
          end
        else
          rows << [parent_id]
        end
      end
    end
  end

  private

  def ensure_result_groups!
    return true unless self.result_groups.nil?
    return true unless self.query.present? || self.parent_ids.present?
    self.result_groups = build_result_groups(*parent_and_child_lings_property_ids)
  end

  def parent_and_child_lings_property_ids
    ids = [self.parent_ids, self.child_ids].compact

    return ids if ids.any?

    filter_lings_property_ids_from_query
  end

  def build_result_groups(parent_ids, child_ids = nil)
    ResultMapper.build_result_groups(parent_ids, child_ids)
  end

  def filter_lings_property_ids_from_query
    SearchFilterBuilder.new(query_adapter).filtered_parent_and_child_ids
  end

  def query_adapter
    @query_adapter ||= QueryAdapter.new(self.group, self.query)
  end

end