class SearchesController < GroupDataController

  before_filter :check_max_search_notice, :only => [:new, :preview, :index]
  rescue_from Exceptions::ResultSearchError, :with => :rescue_from_result_error

  respond_to :html, :js, :csv

  def new
    @search = Search.new do |s|
      s.creator = current_user
      s.group   = current_group
    end

    authorize! :search, @search

    respond_with(@search) do |format|
      format.html
      format.js
    end
  end

  def preview
    @search = perform_search

    #Rails.logger.debug "DEBUG: Step 1 => #{self.class}"
    authorize! :search, @search
    
    # @search.get_results!
  end

  def create
    @search = Search.new(params[:search]) do |s|
      s.creator = current_user
      s.group   = current_group
    end
    authorize! :create, @search

    if @search.save
      redirect_to [current_group, :searches]
    else
      render :preview
    end
  end

  def show
    @search = current_group.searches.find(params[:id])
    if(params[:page])
      @search.offset = params[:page]
    end
    
    authorize! :search, @search

    respond_with(@search) do |format|
      format.html
      format.js
      format.csv {
        send_data SearchCSV.new(@search).to_csv,
                  :type => "text/csv; charset=utf-8; header=present",
                  :filename => "terraling-#{@search.name}.csv" }
    end
  end

  def index
    @searches = current_user.present? ? current_group.searches.by(current_user) : [ Search.new ]
    collection_authorize! :update, @searches

    @search_comparison = SearchComparison.new do |sc|
      sc.creator  = current_user
      sc.group    = current_group
      sc.searches = @searches
    end
  end

  def destroy
    @search = current_group.searches.find(params[:id])
    authorize! :destroy, @search

    @search.destroy
    redirect_to [current_group, :searches], :notice => "You successfully deleted your search."
  end

  def lings_in_selected_row
    @search = perform_search

    @presenter_results = SearchCross.new(params[:cross_ids]).filter_lings_row(@search).paginate(:page => params[:page], :order => "name")
    authorize! :cross, @search
  end

  def geomapping
    @search = perform_search
    
    geoMapping = GeoMapping.new(@search)
    @json = check_retrieved_json(geoMapping.get_json)
    @summary = geoMapping.get_legend

    authorize! :mapping, @search

    respond_with(@search) do |format|
      format.html
      format.js
    end
  end

  protected

  def check_max_search_notice
    return unless user_signed_in? || flash[:notice]
    # TODO replace with class method
    if Search.where(:creator_id => current_user, :group_id => current_group).count >= Search::MAX_SEARCH_LIMIT
      flash.now[:notice] = "You have reached the system limit for saved searches (#{Search::MAX_SEARCH_LIMIT}). Please delete old searches before saving new ones."
    end
  end

  def rescue_from_result_error(exception)
    flash[:notice] = exception.message
    redirect_to :action => :new
  end

  def check_retrieved_json(json)
    if json == "[]"
      flash[:notice] = "Sorry, no geographical data to show on the map!"
      json=''
    end
    json
  end

  def perform_search
    Search.new do |s|
      s.creator = current_user
      s.group = current_group
      s.query = params[:search]
      s.offset = params[:page]
    end
  end

end
