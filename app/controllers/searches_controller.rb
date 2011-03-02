class SearchesController < GroupDataController

  def new
    @search = Search.new(current_group, params[:search])
  end

  def create
    @search = Search.new(current_group, params[:search])
    # Check if search if valid
    render :results
  end
  
  def results
  end

end
