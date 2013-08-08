class LingsPropertiesController < GroupDataController

  respond_to :html, :js
  
  def index
    @lings_properties = current_group.lings_properties.paginate(:page => params[:page], :order=> "value").
        includes(:ling, :property)

    respond_with(@lings_properties) do |format|
      format.html
      format.js
    end
  end

  def show
    @lings_property = current_group.lings_properties.find(params[:id])

    respond_with(@lings_property) do |format|
      format.html
      format.js
    end
  end

  def destroy
    @lings_property = current_group.lings_properties.find(params[:id])
    authorize! :destroy, @lings_property

    @lings_property.destroy

    redirect_to(group_lings_properties_url(current_group))
  end
end
