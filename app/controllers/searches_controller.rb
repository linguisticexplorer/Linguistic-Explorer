class SearchesController < GroupDataController

  before_filter :authenticate_user!, :only => [:index]

  def new
    @search = Search.new do |s|
      s.user  = current_user
      s.group = current_group
      s.query = params[:search]
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
    @search = Search.new do |s|
      s.user  = current_user
      s.group = current_group
      s.query = params[:search]
    end
  end

  def index
    @searches = Search.where(:user => current_user, :group => current_group)
  end

end
