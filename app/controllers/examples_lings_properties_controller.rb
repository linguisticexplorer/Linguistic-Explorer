class ExamplesLingsPropertiesController < GroupDataController

  # GET /examples_lings_properties
  # GET /examples_lings_properties.xml
  def index
    @examples_lings_properties = current_group.examples_lings_properties.includes({:example => :stored_values}, :lings_property)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @examples_lings_properties }
    end
  end

  # GET /examples_lings_properties/1
  # GET /examples_lings_properties/1.xml
  def show
    @examples_lings_property = current_group.examples_lings_properties.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @examples_lings_property }
    end
  end

  # GET /examples_lings_properties/new
  # GET /examples_lings_properties/new.xml
  def new
    @examples_lings_property = ExamplesLingsProperty.new do |elp|
      elp.group = current_group
      elp.creator = current_user
    end

    authorize! :create, @examples_lings_property

    @examples = current_group.examples
    @lings_properties = current_group.lings_properties

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => [@examples_lings_property, @examples, @lings_properties] }
    end
  end

  # POST /examples_lings_properties
  # POST /examples_lings_properties.xml
  def create
    @examples_lings_property = ExamplesLingsProperty.new(params[:examples_lings_property]) do |elp|
      elp.group = current_group
      elp.creator = current_user
    end

    authorize! :create, @examples_lings_property

    respond_to do |format|
      if @examples_lings_property.save
        format.html { redirect_to(group_examples_lings_property_url(current_group, @examples_lings_property), :notice => (current_group.examples_lings_property_name + ' was successfully created.')) }
        format.xml  { render :xml => @examples_lings_property, :status => :created, :location => @examples_lings_property }
      else
        @examples = current_group.examples
        @lings_properties = current_group.lings_properties
        format.html { render :action => "new" }
        format.xml  { render :xml => @examples_lings_property.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /examples_lings_properties/1
  # DELETE /examples_lings_properties/1.xml
  def destroy
    @examples_lings_property = ExamplesLingsProperty.find(params[:id])
    @examples_lings_property = current_group.examples_lings_properties.find(params[:id])
    authorize! :destroy, @examples_lings_property

    @examples_lings_property.destroy

    respond_to do |format|
      format.html { redirect_to(group_examples_lings_properties_url(current_group)) }
      format.xml  { head :ok }
    end
  end
end
