class PropertiesController < GroupDataController
  def index
    @properties = current_group.properties
  end

  def show
    @property = current_group.properties.find(params[:id])
  end

  def new
    @property = Property.new do |p|
      p.group = current_group
      p.creator = current_user
    end
    authorize! :create, @property

    @categories = {
          :depth_0 => current_group.categories.at_depth(0),
          :depth_1 => current_group.categories.at_depth(1)
    }
  end

  def edit
    @property = current_group.properties.find(params[:id])
    authorize! :update, @property

    @categories = {
          :depth_0 => current_group.categories.at_depth(0),
          :depth_1 => current_group.categories.at_depth(1)
    }
  end

  def create
    @property = Property.new(params[:property]) do |property|
      property.group = current_group
      property.creator = current_user
    end
    authorize! :create, @property

    if @property.save
      redirect_to(group_property_url(current_group, @property), :notice => (current_group.property_name + ' was successfully created.'))
    else
      @categories = {
            :depth_0 => current_group.categories.at_depth(0),
            :depth_1 => current_group.categories.at_depth(1)
      }
      render :action => "new"
    end
  end

  def update
    @property = current_group.properties.find(params[:id])
    authorize! :update, @property

    if @property.update_attributes(params[:property])
      redirect_to(group_property_url(current_group, @property), :notice => (current_group.property_name + ' was successfully updated.'))
    else
      @categories = {
            :depth_0 => current_group.categories.at_depth(0),
            :depth_1 => current_group.categories.at_depth(1)
      }
      render :action => "edit"
    end
  end

  def destroy
    @property = current_group.properties.find(params[:id])
    authorize! :destroy, @property

    @property.destroy

    redirect_to(group_properties_url(current_group))
  end
end
