class SearchComparisonsController < GroupDataController
  DATA_MODEL_NAME = :search_comparison

  def new
    @search_comparison  = SearchComparison.new() do |sc|
      sc.creator = current_user
      sc.group   = current_group
    end
  end

  def create
    @search_comparison  = SearchComparison.new(params[:comparison]) do |sc|
      sc.creator = current_user
      sc.group   = current_group
    end

    @search = @search_comparison.search

    render :template => 'searches/preview'
  end
end
