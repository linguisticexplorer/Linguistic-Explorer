class ExamplesLingsPropertiesController < GroupDataController
  def index
    @examples_lings_properties = current_group.examples_lings_properties.includes({:example => :stored_values}, :lings_property).
        paginate(:page => params[:page], :order => "examples.name")
  end

  def show
    @examples_lings_property = current_group.examples_lings_properties.find(params[:id])
  end

  def new
    @examples_lings_property = ExamplesLingsProperty.new do |elp|
      elp.group = current_group
      elp.creator = current_user
    end
    authorize! :create, @examples_lings_property

    @examples = current_group.examples
    @lings_properties = current_group.lings_properties
  end

  def create
    @examples_lings_property = ExamplesLingsProperty.new(params[:examples_lings_property]) do |elp|
      elp.group = current_group
      elp.creator = current_user
    end
    authorize! :create, @examples_lings_property

    if @examples_lings_property.save
      redirect_to([current_group, @examples_lings_property], :notice => (current_group.examples_lings_property_name + ' was successfully created.'))
    else
      @examples = current_group.examples
      @lings_properties = current_group.lings_properties
      render :action => "new"
    end
  end

  def destroy
    @examples_lings_property = ExamplesLingsProperty.find(params[:id])
    @examples_lings_property = current_group.examples_lings_properties.find(params[:id])

    authorize! :destroy, @examples_lings_property
    @examples_lings_property.destroy

    redirect_to(group_examples_lings_properties_url(current_group))
  end
end
