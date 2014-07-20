class LingsPropertiesController < GroupDataController

  respond_to :html, :js

  def show
    @lings_property = current_group.lings_properties.find(params[:id])

    is_authorized? :read, @lings_property

    respond_with(@lings_property) do |format|
      format.html
      format.js
    end
  end

  def destroy
    @lings_property = current_group.lings_properties.find(params[:id])
    is_authorized? :destroy, @lings_property, true

    @lings_property.destroy

    redirect_to(current_group)
  end

  def exists
    if params[:ling_name] && params[:prop_name]
      ling = current_group.lings.find_by_name(params[:ling_name])
      prop = current_group.properties.find_by_name(params[:prop_name])
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
