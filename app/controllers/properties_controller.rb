class PropertiesController < GroupDataController

  # GET /properties
  # GET /properties.xml
  def index
    @properties = Property.all
    authorize! :read, @properties

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @properties }
    end
  end

  # GET /properties/1
  # GET /properties/1.xml
  def show
    @property = Property.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @property }
    end
  end

  # GET /properties/new
  # GET /properties/new.xml
  def new
    @property = Property.new
    @categories = {
          :depth_0 => Category.find_all_by_depth(0),
          :depth_1 => Category.find_all_by_depth(1)
    }

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => [@property, @categories] }
    end
  end

  # GET /properties/1/edit
  def edit
    @property = Property.find(params[:id])
    @categories = {
          :depth_0 => Category.find_all_by_depth(0),
          :depth_1 => Category.find_all_by_depth(1)
    }
  end

  # POST /properties
  # POST /properties.xml
  def create
    @property = Property.new(params[:property]) do |property|
      property.group = current_group
      property.creator = current_user
    end

    respond_to do |format|
      if @property.save
        format.html { redirect_to(group_property_url(current_group, @property), :notice => (current_group.property_name + ' was successfully created.')) }
        format.xml  { render :xml => @property, :status => :created, :location => @property }
      else
        @categories = {
              :depth_0 => Category.find_all_by_depth(0),
              :depth_1 => Category.find_all_by_depth(1)
        }
        format.html { render :action => "new" }
        format.xml  { render :xml => @property.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /properties/1
  # PUT /properties/1.xml
  def update
    @property = Property.find(params[:id])

    respond_to do |format|
      if @property.update_attributes(params[:property])
        format.html { redirect_to(group_property_url(current_group, @property), :notice => (current_group.property_name + ' was successfully updated.')) }
        format.xml  { head :ok }
      else
        @categories = {
              :depth_0 => Category.find_all_by_depth(0),
              :depth_1 => Category.find_all_by_depth(1)
        }
        format.html { render :action => "edit" }
        format.xml  { render :xml => @property.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /properties/1
  # DELETE /properties/1.xml
  def destroy
    @property = Property.find(params[:id])
    @property.destroy

    respond_to do |format|
      format.html { redirect_to(group_properties_url(current_group)) }
      format.xml  { head :ok }
    end
  end
end
