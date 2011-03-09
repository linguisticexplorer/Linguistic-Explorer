class LingsController < GroupDataController
  helper :groups

  # GET /lings
  # GET /lings.xml
  def index
    @lings = Ling.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lings }
    end
  end

  # GET /lings/1
  # GET /lings/1.xml
  def show
    @ling = Ling.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ling }
    end
  end

  # GET /lings/new
  # GET /lings/new.xml
  def new
    @ling = Ling.new()
    @lings = Ling.find_all_by_depth(0)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => [@ling, @lings] }
    end
  end

  # GET /lings/1/edit
  def edit
    @ling = Ling.find(params[:id])
    @lings = Ling.find_all_by_depth(0)
  end

  # POST /lings
  # POST /lings.xml
  def create
    @ling = Ling.new(params[:ling]) do |ling|
      ling.group    = current_group
      ling.creator  = current_user
    end

    respond_to do |format|
      if @ling.save
        format.html { redirect_to([current_group, @ling], :notice => (current_group.ling_name_for_depth(@ling.depth) + ' was successfully created.')) }
        format.xml  { render :xml => @ling, :status => :created, :location => @ling }
      else
        @lings = Ling.find_all_by_depth(0)
        format.html { render :action => "new" }
        format.xml  { render :xml => @ling.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /lings/1
  # PUT /lings/1.xml
  def update
    @ling = Ling.find(params[:id])

    respond_to do |format|
      if @ling.update_attributes(params[:ling])
        format.html { redirect_to(group_ling_url(current_group, @ling), :notice => (current_group.ling_name_for_depth(@ling.depth) + ' was successfully updated.') ) }
        format.xml  { head :ok }
      else
        @lings = Ling.find_all_by_depth(0)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ling.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /lings/1
  # DELETE /lings/1.xml
  def destroy
    @ling = Ling.find(params[:id])
    @ling.destroy

    respond_to do |format|
      format.html { redirect_to(group_lings_url(current_group)) }
      format.xml  { head :ok }
    end
  end
end
