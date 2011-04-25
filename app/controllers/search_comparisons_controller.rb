class SearchComparisonsController < GroupDataController

  def new
    @comparison  = SearchComparison.new() do |sc|
      sc.creator = current_user
      sc.group   = current_group
    end
  end

  def create
    @comparison  = SearchComparison.new(params[:comparison]) do |sc|
      sc.creator = current_user
      sc.group   = current_group
    end

    @search = @comparison.search

    render :template => 'searches/preview'
  end
end
