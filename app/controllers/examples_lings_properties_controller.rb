class ExamplesLingsPropertiesController < GroupDataController

  # GET /examples_lings_properties
  # GET /lings_properties.xml
  def index
#    @examples_lings_properties = ExamplesLingsProperty.all
#
#    respond_to do |format|
#      format.html # index.html.erb
#      format.xml  { render :xml => @examples_lings_properties }
#    end
  end

  # GET /examples_lings_properties/1
  # GET /examples_lings_properties/1.xml
  def show
#    @examples_lings_property = ExamplesLingsProperty.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @examples_lings_property }
#    end
  end

  # GET /examples_lings_properties/new
  # GET /examples_lings_properties/new.xml
  def new
#    @examples_lings_property = ExamplesLingsProperty.new
#    @lings = Ling.all
#    @properties = Property.all
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => [@examples_lings_property, @lings, @properties] }
#    end
  end

  # GET /examples_lings_properties/1/edit
  def edit
#    @examples_lings_property = ExamplesLingsProperty.find(params[:id])
#    @lings = Ling.all
#    @properties = Property.all
  end

  # POST /examples_lings_properties
  # POST /examples_lings_properties.xml
  def create
#    @examples_lings_property = ExamplesLingsProperty.new(params[:lings_property]) do |examples_lings_property|
#      examples_lings_property.group = current_group
#      examples_lings_property.creator = current_user
#    end
#
#    respond_to do |format|
#      if @examples_lings_property.save
#        format.html { redirect_to(group_examples_lings_property_url(current_group, @examples_lings_property), :notice => (current_group.examples_lings_property_name + ' was successfully created.')) }
#        format.xml  { render :xml => @examples_lings_property, :status => :created, :location => @examples_lings_property }
#      else
#        @lings = Ling.all
#        @properties = Property.all
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @examples_lings_property.errors, :status => :unprocessable_entity }
#      end
#    end
  end

  # PUT /examples_lings_properties/1
  # PUT /examples_lings_properties/1.xml
  def update
#    @examples_lings_property = ExamplesLingsProperty.find(params[:id])
#
#    respond_to do |format|
#      if @examples_lings_property.update_attributes(params[:examples_lings_property])
#        format.html { redirect_to(group_examples_lings_property_url(current_group, @examples_lings_property), :notice => (current_group.examples_lings_property_name + ' was successfully updated.')) }
#        format.xml  { head :ok }
#      else
#        @lings = Ling.all
#        @properties = Property.all
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @examples_lings_property.errors, :status => :unprocessable_entity }
#      end
#    end
  end

  # DELETE /examples_lings_properties/1
  # DELETE /examples_lings_properties/1.xml
  def destroy
#    @examples_lings_property = ExamplesLingsProperty.find(params[:id])
#    @examples_lings_property.destroy
#
#    respond_to do |format|
#      format.html { redirect_to(group_examples_lings_properties_url(current_group)) }
#      format.xml  { head :ok }
#    end
  end
end
