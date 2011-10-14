class LingsPropertiesController < GroupDataController
  def index
    @lings_properties = current_group.lings_properties.paginate(:page => params[:page], :order=> "value").
        includes(:ling, :property)
  end

  def show
    @lings_property = current_group.lings_properties.find(params[:id])
  end

  def destroy
    @lings_property = current_group.lings_properties.find(params[:id])
    authorize! :destroy, @lings_property

    @lings_property.destroy

    redirect_to(group_lings_properties_url(current_group))
  end
end
