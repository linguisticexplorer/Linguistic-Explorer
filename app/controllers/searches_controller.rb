class SearchesController < GroupDataController

  before_filter :authenticate_user!, :only => [:index]

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
  end

  def index
    @searches = Search.where(:user => current_user, :group => current_group)
  end

end
