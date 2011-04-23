class SearchesController < GroupDataController

  before_filter :authenticate_user!, :only => [:index]
  before_filter :check_max_search_notice, :only => [:new, :preview, :index]

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

    # @search.get_results!
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
        :type => "text/csv; charset=utf-8; header=present",
        :filename => "terraling-#{@search.name}.csv" }
    end
  end

  def index
    @searches   = Search.where(:user => current_user, :group => current_group)
    @comparison = SearchComparison.new do |sc|
      sc.user   = current_user
      sc.group  = current_group
      sc.searches = @searches
    end
  end

  def destroy
    @search = Search.find(params[:id])
    @search.destroy
    redirect_to [current_group, :searches], :notice => "You successfully deleted your search."
  end

protected

  def check_max_search_notice
    return unless user_signed_in? || flash[:notice]
    if Search.where(:user => current_user, :group => current_group).count >= 25
      flash.now[:notice] = "You have reached the system limit for saved searches (25). Please delete old searches before saving new ones."
    end
  end
end
