class GeoMapping
  
  def initialize(search)
  	@search = search
  	@search_results = @search.results(false)
  	@lings_hash = Hash.new
  end
  
  def get_json
  	json = ''
  	get_lings_hash.each do |row_number, ling_list|
  		lings = Ling.where(:id => ling_list).to_a
  		if ling_list.any?
  			json = json + lings.to_gmaps4rails do |ling, marker|
          marker.infowindow info_window(ling, row_number)
  				marker.picture({
						:picture => "/images/markers/marker#{row_number}.png",
						:width 	=> "32",
						:height 	=> "37"
				})
  			end
  		end
  	end
  	json.gsub('][', ",")
  end
  
  private

  def info_window(ling, row_number)
    if @search.cross?
      "#{ling.name} <br /> Row number: #{row_number}"
    else
      ling.name
    end
  end

  def get_lings_hash
  	if @search.default?
  		default_search
  	elsif @search.compare?
  		compare_search
  	elsif @search.cross?
  		cross_search
  	end
  	@lings_hash
  end
  
  
  def compare_search
  	result = @search_results.first
  	@lings_hash["1"] = []
  	for ling in result.lings
  		store_id(@lings_hash["1"], ling.id)
  	end
  end
  
  def cross_search
  	marker_list = 1
  	for result in @search_results
  		@lings_hash["#{marker_list}"] = []
  		for lingsProperty in result.child
  			store_id(@lings_hash["#{marker_list}"], lingsProperty.ling_id)
  		end
  		marker_list = marker_list + 1
  	end
  end
  
  def default_search
  	@lings_hash["1"] = []
  	@lings_hash["2"] = []
  	for result in @search_results
  		store_id(@lings_hash["1"], result.parent.ling_id)
  		if result.child != nil
  			store_id(@lings_hash["2"], result.child.ling_id)
  		end
  	end
  end
  def store_id(array, id) 
  	if ! array.include?(id)
  		array << id
  	end
  end
end
