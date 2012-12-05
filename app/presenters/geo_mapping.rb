class GeoMapping

  def initialize(search)
    @lings_hash = {}
    @titles_hash = {}
    @search_type = ''
    create_lings_hash(search)
  end

  def get_legend
    {
      title: @search_type,
      lings: @titles_hash.keys.size,
      rows: get_rich_legend
    }
  end

  def get_json
    json = ''
    @lings_hash.each do |row_number, lings_list|
      if lings_list.any?
        json << lings_list.to_gmaps4rails do |ling, marker|
          marker.infowindow info_window_for ling, row_number
          marker.title rollover_information(ling, row_number)
          marker.picture({
                             :picture => get_marker_url(row_number.to_i),
                             :width 	=> 32,
                             :height 	=> 37
                         })
        end
      end
    end
    json.gsub('][', ",")
  end

  private
  
  # See: http://martin.ankerl.com/2009/12/09/how-to-create-random-colors-programmatically/
  def get_marker_url(number)
    hex_value = ""
    # use golden ratio
    golden_ratio_conjugate = 0.618033988749895
    h = number * golden_ratio_conjugate * 1000 # use random start value
    h += golden_ratio_conjugate
    h %= 1
    hsv_to_rgb(h, 0.5, 0.95).each { |component| hex_value << component.to_s(16) }
    "http://thydzik.com/thydzikGoogleMap/markerlink.php?text=#{number}&color=#{hex_value}"
  end

  # Thanks to:
  # http://martin.ankerl.com/2009/12/09/how-to-create-random-colors-programmatically/
  # HSV values in [0..1[
  # returns [r, g, b] values from 0 to 255
  def hsv_to_rgb(h, s, v)
    h_i = (h*6).to_i
    f = h*6 - h_i
    p = v * (1 - s)
    q = v * (1 - f*s)
    t = v * (1 - (1 - f) * s)
    r, g, b = v, t, p if h_i==0
    r, g, b = q, v, p if h_i==1
    r, g, b = p, v, t if h_i==2
    r, g, b = p, q, v if h_i==3
    r, g, b = t, p, v if h_i==4
    r, g, b = v, p, q if h_i==5
    [(r*256).to_i, (g*256).to_i, (b*256).to_i]
  end

  def get_rich_legend
    [].tap do |row|
      @lings_hash.each do |number, list|
        if list.any?
          row << {
            id: "id_#{number}",
            icon: get_marker_url(number.to_i),
            size: list.size,
            content: get_legend_content(number, list)
          }
        end
      end
    end  
  end

  def get_legend_content(row, list)
    if @search_type =~ /Regular|Compare/
      return 'all' # also for Compare
    else
      return rollover_information(list[0], row) # for Cross and Implication use rollover info!!
    end
  end

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
      @search_type = 'Regular Search'
      lings_in_default_search(search_results)
    elsif search.compare?
      @search_type = 'Compare Search'
      lings_in_compare_search(search_results)
    elsif search.cross?
      @search_type = 'Cross Search'
      lings_in_cross_search(search_results)
    else
      @search_type = 'Implication Search'
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