class SearchJSON
  include SearchColumns

  def initialize(search)
    @search = search
  end

  def build_json
    {
      :type    => @search.getType,
      :header  => build_results_header,
      :rows => @search.results(false)
    }.
    to_json.
    html_safe
  end

  private

  def build_results_header
    header ||= {}.tap do |entry|
      result_headers.each do |key_value|
        entry[key_value[:key]] = key_value[:value].call(@search.group)
      end
    end
  end

end