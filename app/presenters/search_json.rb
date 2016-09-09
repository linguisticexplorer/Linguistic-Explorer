class SearchJSON
  include SearchColumns
  include SearchCompareResultsHelper

  def initialize(search)
    @search = search
  end

  def build_json
    {
      :type    => get_search_type(),
      :header  => build_results_header,
      :rows    => @search.results(false),
      :success => true
    }.to_json.html_safe
  end

  private

  def build_results_header
    # clustering results have no header
    return '' if /clustering/.match @search.getType

    header ||= {}.tap do |entry|
      if /compare/.match @search.getType

        build_compare_headers entry, @search.results(false)
        
      else

        build_headers entry

      end
    end
  end

  def get_search_type
    type = @search.getType
    /clustering/.match(type) ? "clustering" : type
  end

  def build_compare_headers(entry, rows)
    entry[:commons] = Hash.new
    # common results
    commons  = results_in_common_compare_search(rows)
    unless commons.empty?
      result_headers(value_for_header(commons)).each do |key_value|
        entry[:commons][key_value[:key]] = key_value[:value].call( @search.group )
      end
    end

    # diff results
    entry[:differents] = Hash.new
    differents = results_diff_compare_search(rows)
    unless differents.empty?
      values_for_header = value_for_header(differents)
      diff_headers = result_headers(values_for_header)

      # First column: this is the property column
      entry[:differents][diff_headers[0][:key]] = diff_headers[0][:value].call( @search.group )
      # Other columns: one column per language here
      entry[:differents][diff_headers[1][:key]] = Array.new
      values_for_header.each do |value|
        entry[:differents][diff_headers[1][:key]] << diff_headers[1][:value].call(value)
      end
    end
  end

  def build_headers(entry)
    result_headers.each do |key_value|
      entry[key_value[:key]] = key_value[:value].call(@search.group)
    end
  end

end