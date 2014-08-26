class GeoMapping

  def initialize(group, params)
    @group = group
    @lings = params[:ling_ids]
    @props = params[:prop_ids]
  end

  def find_values

    # get the latlong id
    latlong_id = @group.properties.where(:name => 'latlong')
                 .pluck(:id).first
    
    # create a simple hash to send as json
    get_coords(@lings, @props, latlong_id).to_json.html_safe
  end

  private

  def get_coords(ling_ids, prop_ids, latlong_id)

    ling_ids = find_lings_for_props(prop_ids || []) if ling_ids.nil?

    latlongs = @group.
    # query to get the ling properties for that group
      lings_properties.
    # filter by property and ling ids
      where(:ling_id => ling_ids, :property_id => latlong_id ).
    # get only two columns
    # Note:
    # In Rails 3.2 pluck accepts one columns only, so it is not usable here
    # Since Rails 4.0 it will work with multiple columns as well 
      select([:ling_id, :value]).to_a
    
    # Create now an hash to map in JSON => JS Object
    # E.g.
    # {
    #   "15" : ["lat", "long"],
    #   ...
    # }

    values = {}.tap do |entry|
      latlongs.each do |lp|
        lat  = ''
        long = ''
        if(lp.value.present?)
          lat  = lp.value.split(/,/).first
          long = lp.value =~ /,/ ? lp.value.split(/,/).last : ''
        end
        entry["#{lp.ling_id}"] = [lat, long]
      end
    end
    # this is the result returned
    {
      :type => :coords,
      :values => values
    }
  end

  def find_lings_for_props(props_ids)

    # find the lings with the properties
    @group.lings_properties.
      where(:property_id => props_ids).select(:ling_id)

  end            


  # def get_legend
  #   {
  #     title: @data[:type],
  #     lings: @data[:titles].keys.size,
  #     rows: get_rich_legend
  #   }
  # end
  # def get_json1
  #   json = {}.tap do |entry|
  #     @data[:lings].each do |row_number, lings_list|
  #       if lings_list.any?
  #         entry = Gmaps4rails.build_markers(lings_list) do |ling, marker|
  #           marker.infowindow info_window_for ling, row_number
  #           marker.title rollover_information(ling, row_number)
  #           marker.picture({
  #                              :picture => get_marker_url(row_number),
  #                              :width 	=> 32,
  #                              :height 	=> 37
  #                          })
  #           marker.json({ id: row_number })
  #         end
  #       end
  #     end
  #   end
  #   json.to_json
  # end
  
  # # See: http://martin.ankerl.com/2009/12/09/how-to-create-random-colors-programmatically/
  # def get_marker_url(number)
  #   hex_value = ""
  #   # use golden ratio
  #   golden_ratio_conjugate = 0.618033988749895
  #   # Rails.logger.debug "DEBUG: Colours #{@data[:colours].inspect}, id: #{number} => #{@data[:colours][number.to_s]}"
  #   h = @data[:colours][number.to_s] # use (per category) random start value
  #   h += golden_ratio_conjugate
  #   h %= 1
  #   hsv_to_rgb(h, 0.5, 0.95).each { |component| hex_value << component.to_s(16) }
  #   "http://thydzik.com/thydzikGoogleMap/markerlink.php?text=#{number}&color=#{hex_value}"
  # end

  # # Thanks to:
  # # http://martin.ankerl.com/2009/12/09/how-to-create-random-colors-programmatically/
  # # HSV values in [0..1[
  # # returns [r, g, b] values from 0 to 255
  # def hsv_to_rgb(h, s, v)
  #   h_i = (h*6).to_i
  #   f = h*6 - h_i
  #   p = v * (1 - s)
  #   q = v * (1 - f*s)
  #   t = v * (1 - (1 - f) * s)
  #   r, g, b = v, t, p if h_i==0
  #   r, g, b = q, v, p if h_i==1
  #   r, g, b = p, v, t if h_i==2
  #   r, g, b = p, q, v if h_i==3
  #   r, g, b = t, p, v if h_i==4
  #   r, g, b = v, p, q if h_i==5
  #   [(r*256).to_i, (g*256).to_i, (b*256).to_i]
  # end

  # def get_rich_legend
  #   [].tap do |row|
  #     @data[:lings].each do |number, list|
  #       if list.any?
  #         row << {
  #           id: "id_#{number}",
  #           icon: get_marker_url(number.to_i),
  #           size: list.size,
  #           content: get_legend_content(number, list)
  #         }
  #       end
  #     end
  #   end  
  # end

  # def get_legend_content(row, list)
  #   if @data[:type] =~ /Regular|Compare/
  #     return 'all' # also for Compare
  #   else
  #     return rollover_information(list[0], row) # for Cross and Implication use rollover info!!
  #   end
  # end

  # def info_window_for(ling, list)
  #   return link_to_ling ling if ling.name == rollover_information(ling, list)
  #   group_info = rollover_information(ling, list)
  #   separator = ' => '
  #   separator = ',<br />' unless is_implication?
  #   group_info = group_info.gsub(/, /,separator)
  #   "#{link_to_ling ling}<br /><p>#{group_info}</p>".html_safe
  # end

  # def create_lings_hash(search)
  #   search_results = search.results(false)
  #   if search.default?
  #     @data[:type] = 'Regular Search'
  #     lings_in_default_search(search_results)
  #   elsif search.compare?
  #     @data[:type] = 'Compare Search'
  #     lings_in_compare_search(search_results)
  #   elsif search.cross?
  #     @data[:type] = 'Cross Search'
  #     lings_in_cross_search(search_results)
  #   else
  #     @data[:type] = 'Implication Search'
  #     lings_in_implication_search(search_results)
  #   end
  #   @data[:lings].map {|k,v| v.uniq! }
  # end


  # def lings_in_compare_search(search_results)
  #   result = search_results.first
  #   @data[:lings]["1"] = []
  #   result.lings.each do |ling|
  #     @data[:lings]["1"] << ling
  #   end
  # end

  # def lings_in_cross_search(search_results)
  #   marker_list = 1
  #   search_results.each do |result|
  #     @data[:lings]["#{marker_list}"] = []
  #     @data[:colours]["#{marker_list}"] ||= rand
  #     result.child.each {|lp| @data[:lings]["#{marker_list}"] << lp.ling }
  #     result.child.each {|lp| @data[:titles][lp.ling_id] = result.parent}
  #     marker_list += 1
  #   end
  # end

  # def lings_in_implication_search(search_results)
  #   marker_list = 1
  #   search_results.each do |result|
  #     @data[:lings]["#{marker_list}"] = []
  #     @data[:colours]["#{marker_list}"] ||= rand
  #     result.child.each {|lp| @data[:lings]["#{marker_list}"] << lp.ling }
  #     result.child.each {|lp| @data[:titles]["#{lp.ling_id}:#{marker_list}"] = result.parent}
  #     marker_list += 1
  #   end
  # end

  # def lings_in_default_search(search_results)
  #   @data[:lings] = {"1" => [], "2" => [] }
  #   @data[:colours] = {"1" => rand, "2" => rand }
  #   search_results.each do |result|
  #     @data[:lings]["1"] << result.parent.ling
  #     @data[:titles][result.parent.ling.id] = result.parent.ling.name
  #     if result.child.present?
  #       @data[:lings]["2"] << result.child.ling
  #       @data[:titles][result.child.ling.id] = result.child.ling.name
  #     end
  #   end
  # end

  # def rollover_information(ling, list)
  #   if !is_implication?
  #     title = @data[:titles][ling.id]
  #   else
  #     title = @data[:titles]["#{ling.id}:#{list}"]
  #   end
  #   return title if title.is_a? String
  #   title.map {|lp| "#{lp.property.name} : #{lp.value} , "}.join("").gsub(/, $/, "")
  # end

  # def link_to_ling(ling)
  #   "<a href='/groups/#{ling.group.to_param}/lings/#{ling.to_param}'>#{ling.name}</a>".html_safe
  # end

  # def is_implication?
  #   @data[:type] == 'Implication Search'
  # end

end