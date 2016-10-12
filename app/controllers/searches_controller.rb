class SearchesController < GroupDataController

  before_filter :check_max_search_notice, :only => [:new, :preview, :index]
  rescue_from Exceptions::ResultSearchError, :with => :rescue_from_result_error
  rescue_from Exceptions::SearchError, :with => :rescue_from_search_error

  respond_to :html, :csv

  def new
    @search = Search.new do |s|
      s.creator = current_user
      s.group   = current_group
    end

    is_authorized? :search, @search

    respond_with(@search) do |format|
      format.html
      format.js
    end
  end

  def preview

    raise Exceptions::SearchError if params.nil? || params[:search].nil? 

    @dynamic_results = true
    # params[:search][:javascript] == "true"

    if @dynamic_results

      @query = params[:search].to_json.html_safe || ''
      # Create a clean search object
      @search = Search.new do |s|
        s.creator = current_user
        s.group   = current_group
      end

    else
      # Perform the old-fashioned search with pagination
      @search = perform_search

    end

    is_authorized? :search, @search

    # perhaps a switch for non-javascript things here?
    respond_with(@search) do |format|
      format.html
      format.js
    end
  end

  def get_results
    search = params[:id].present? ? current_group.searches.find(params[:id]) : perform_search

    is_authorized? :search, search

    render :json => SearchJSON.new(search).build_json
  end

  def create
    
    @search = Search.new(params[:search]) do |s|
      s.creator = current_user
      s.group   = current_group
    end

    is_authorized? :create, @search

    if @search.save
      render :json => {:success => true} 
      # redirect_to [current_group, :searches]
    else
      render :json => {:success => false, :errors => @search.errors } 
      # render :preview
    end
  end

  def show
    # Deal with the legacy GET route
    # if params[:id] == "preview"
    #   return redirect_to :action => :new
    # end

    @search = current_group.searches.find(params[:id])
    
    is_authorized? :search, @search

    @query = @search.query

    respond_with(@search) do |format|
      format.html  { render :template => 'searches/preview' }
      # format.js    { render :template => 'searches/preview' }
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
    is_authorized? :destroy, @search

    @search.destroy
    redirect_to [current_group, :searches], :notice => "You successfully deleted your search."
  end

  def geomapping
    # an empty one is enough
    search = Search.new do |s|
      s.creator = current_user
      s.group   = current_group
    end
    
    # authorize before doing the effort

    is_authorized? :search, search
    
    @geoMapping = GeoMapping.new(current_group, params).find_values

    render :json => @geoMapping
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
    render :json => {:success => false, :errors => exception.message } 
  end

  def rescue_from_search_error(exception)
    flash[:alert] = exception.message
    redirect_to :action => :new
  end

  def perform_search(offset=0)
    Search.new do |s|
      s.creator = current_user
      s.group         = current_group
      s.query         = params[:search]
      s.result_groups = params[:result_groups]
      s.offset        = offset
    end
  end

end
