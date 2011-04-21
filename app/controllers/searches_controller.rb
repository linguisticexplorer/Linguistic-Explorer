class SearchesController < GroupDataController

  before_filter :authenticate_user!, :only => [:index]

  respond_to :html, :csv

  def new
    @search = Search.new do |s|
      s.user  = current_user
      s.group = current_group
    end
  end

  def preview
    @search = Search.new do |s|
      s.user  = current_user
      s.group = current_group
      s.query = params[:search]
    end
  end

  def create
    params_search = params[:search]

    @search = Search.new(params[:search]) do |s|
      s.user  = current_user
      s.group = current_group
    end

    if @search.save
      redirect_to [current_group, :searches]
    else
      render :preview
    end
  end

  def show
    @search = Search.find(params[:id])
    respond_with(@search) do |format|
      format.html
      format.csv {
        send_data SearchCSV.new(@search).to_csv,
        :type => "text/csv",
        :filename => "terraling-#{@search.name}.csv" }
    end
  end

  def index
    @searches = Search.where(:user => current_user, :group => current_group)
  end
  
  def destroy
    @search = Search.find(params[:id])
    @search.destroy
    redirect_to [current_group, :searches], :notice => "You successfully deleted your search."
  end

end
