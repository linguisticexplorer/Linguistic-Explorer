class SearchComparisonsController < GroupDataController
  def new
    @search_comparison  = SearchComparison.new do |sc|
      sc.creator = current_user
      sc.group   = current_group
    end
    authorize! :create, @search_comparison
  end

  def create
    @search_comparison  = SearchComparison.new(params[:comparison]) do |sc|
      sc.creator = current_user
      sc.group   = current_group
    end
    authorize! :create, @search_comparison

    if @search_comparison.save
      @search = @search_comparison.search

      @dynamic_results = true

      @query = @search.query.to_json.html_safe

      @result_groups = @search.result_groups.to_json.html_safe

      render :template => 'searches/preview'
    else
      flash.now[:notice] = "Please select a comparison and two searches"
      render :action => :new
    end
  end
end
