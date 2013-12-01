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
    # @search = perform_search

    #Rails.logger.debug "DEBUG: Step 1 => #{self.class}"
    # authorize! :search, @search
    
    # @search.get_results!

    @search = Search.new do |s|
      s.creator = current_user
      s.group   = current_group
    end

    @query = params[:search].to_json.html_safe

    authorize! :search, @search

    respond_with(@search) do |format|
      format.html
      format.js
    end
  end

  def get_results
    search = perform_search

    json = SearchJSON.new(search).build_json
    

    #Rails.logger.debug "DEBUG: Step 1 => #{self.class}"
    authorize! :search, search

    render :json => json
  end

  def create
    @search = Search.new(params[:search]) do |s|
      s.creator = current_user
      s.group   = current_group
    end
    authorize! :create, @search

    if @search.save
      render :json => {:success => true} 
      # redirect_to [current_group, :searches]
    else
      render :json => {:success => false, :errors => @search.errors } 
      # render :preview
    end
  end

  def show
    @search = current_group.searches.find(params[:id])
    
    authorize! :search, @search

    @query = @search.query.to_json.html_safe

    respond_with(@search) do |format|
      format.html  { render :template => 'searches/preview' }
      format.js    { render :template => 'searches/preview' }
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

  def geomapping
    # @search = perform_search
    
    # geoMapping = GeoMapping.new(@search)
    # @json = check_retrieved_json(geoMapping.get_json)
    # @summary = geoMapping.get_legend
    # @summary = {}

    # authorize! :mapping, @search

    # respond_with(@search) do |format|
    #   format.html
    #   format.js
    # end

    # collect all geographic informations about languages to map
    @geoMapping = GeoMapping.new(params[:ling_ids])
    # @geoMapping = {}

    authorize! :mapping, @geoMapping

    render :json => @geoMapping.to_json.html_safe
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

  def perform_search
    Search.new do |s|
      s.creator = current_user
      s.group = current_group
      s.query = params[:search]
      s.offset = params[:page]
    end
  end

end
