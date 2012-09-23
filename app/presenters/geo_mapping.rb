class GeoMapping

  def initialize(search)
    @lings_hash = {}
    @titles_hash = {}
    create_lings_hash(search)
  end

  def get_json
    json = ''
    @lings_hash.each do |row_number, lings_list|
      if lings_list.any?
        json << lings_list.to_gmaps4rails do |ling, marker|
          marker.infowindow info_window_for ling, row_number
          marker.title rollover_information(ling, row_number)
          marker.picture({
                             :picture => "/images/markers/marker#{row_number}.png",
                             :width 	=> 32,
                             :height 	=> 37
                         })
        end
      end
    end
    json.gsub('][', ",")
  end

  private

  def info_window_for(ling, list)
    return link_to_ling ling if ling.name == rollover_information(ling, list)
    group_info = rollover_information(ling, list)
    separator = ' => '
    separator = ',<br />' unless is_implication?
    group_info = group_info.gsub(/, /,separator)
    "#{link_to_ling ling}<br /><p>#{group_info}</p>".html_safe
  end

  def create_lings_hash(search)
    search_results = search.results(false)
    if search.default?
      lings_in_default_search(search_results)
    elsif search.compare?
      lings_in_compare_search(search_results)
    elsif search.cross?
      lings_in_cross_search(search_results)
    else
      lings_in_implication_search(search_results)
    end
    @lings_hash.map {|k,v| v.uniq! }
  end


  def lings_in_compare_search(search_results)
    result = search_results.first
    @lings_hash["1"] = []
    result.lings.each do |ling|
      @lings_hash["1"] << ling
      @titles_hash[ling.id] = ling.name
    end
  end

  def lings_in_cross_search(search_results)
    marker_list = 1
    search_results.each do |result|
      @lings_hash["#{marker_list}"] = []
      result.child.each {|lp| @lings_hash["#{marker_list}"] << lp.ling }
      result.child.each {|lp| @titles_hash[lp.ling_id] = result.parent}
      marker_list += 1
    end
  end

  def lings_in_implication_search(search_results)
    marker_list = 1
    search_results.each do |result|
      @lings_hash["#{marker_list}"] = []
      result.child.each {|lp| @lings_hash["#{marker_list}"] << lp.ling }
      result.child.each {|lp| @titles_hash["#{lp.ling_id}:#{marker_list}"] = result.parent}
      marker_list += 1
    end
  end

  def lings_in_default_search(search_results)
    @lings_hash["1"] = []
    @lings_hash["2"] = []
    search_results.each do |result|
      @lings_hash["1"] << result.parent.ling
      @titles_hash[result.parent.ling.id] = result.parent.ling.name
      if result.child.present?
        @lings_hash["2"] << result.child.ling
        @titles_hash[result.child.ling.id] = result.child.ling.name
      end
    end
  end

  def rollover_information(ling, list)
    if !is_implication?
      title = @titles_hash[ling.id]
    else
      title = @titles_hash["#{ling.id}:#{list}"]
    end
    return title if title.is_a? String
    title.map {|lp| "#{lp.property.name} : #{lp.value} , "}.join("").gsub(/, $/, "")
  end

  def link_to_ling(ling)
    "<a href='/groups/#{ling.group.to_param}/lings/#{ling.to_param}'>#{ling.name}</a>".html_safe
  end

  def is_implication?
    @titles_hash.keys.first.is_a? String
  end

end