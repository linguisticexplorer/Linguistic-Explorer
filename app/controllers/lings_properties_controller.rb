class LingsPropertiesController < GroupDataController

  # GET /lings_properties
  # GET /lings_properties.xml
  def index
    @lings_properties = LingsProperty.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lings_properties }
    end
  end

  # GET /lings_properties/1
  # GET /lings_properties/1.xml
  def show
    @lings_property = LingsProperty.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lings_property }
    end
  end

  # GET /lings_properties/new
  # GET /lings_properties/new.xml
  def new
    @lings_property = LingsProperty.new
    @lings = Ling.all
    @properties = Property.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => [@lings_property, @lings, @properties] }
    end
  end

  # GET /lings_properties/1/edit
  def edit
    @lings_property = LingsProperty.find(params[:id])
    @lings = Ling.all
    @properties = Property.all
  end

  # POST /lings_properties
  # POST /lings_properties.xml
  def create
    @lings_property = LingsProperty.new(params[:lings_property]) do |lings_property|
      lings_property.group = current_group
      lings_property.creator = current_user
    end

    respond_to do |format|
      if @lings_property.save
        format.html { redirect_to(group_lings_property_url(current_group, @lings_property), :notice => (current_group.lings_property_name + ' was successfully created.')) }
        format.xml  { render :xml => @lings_property, :status => :created, :location => @lings_property }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @lings_property.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /lings_properties/1
  # PUT /lings_properties/1.xml
  def update
    @lings_property = LingsProperty.find(params[:id])

    respond_to do |format|
      if @lings_property.update_attributes(params[:lings_property])
        format.html { redirect_to(group_lings_property_url(current_group, @lings_property), :notice => (current_group.lings_property_name + ' was successfully updated.')) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lings_property.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /lings_properties/1
  # DELETE /lings_properties/1.xml
  def destroy
    @lings_property = LingsProperty.find(params[:id])
    @lings_property.destroy

    respond_to do |format|
      format.html { redirect_to(group_lings_properties_url(current_group)) }
      format.xml  { head :ok }
    end
  end
end
