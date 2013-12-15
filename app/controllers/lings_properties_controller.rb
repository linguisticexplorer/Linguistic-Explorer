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

  def exists
    if params[:ling_name] && params[:prop_name]
      ling = Ling.find_by_name(params[:ling_name])
      prop = Property.find_by_name(params[:prop_name])
      lp = ling && prop && current_group.lings_properties.find_by_ling_id_and_property_id(ling.id, prop.id)
      if lp
        render :json => {exists: true, value: lp.value, id: lp.id} 
      else
        render :json => {exists: false}
      end
    else
    render :json => {error: "Missing ling_name or prop_name in params"}
    end
  end
end
