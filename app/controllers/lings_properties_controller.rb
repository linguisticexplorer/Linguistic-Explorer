class LingsPropertiesController < GroupDataController

  # GET /lings_properties
  # GET /lings_properties.xml
  def index
    @lings_properties = current_group.lings_properties.includes(:ling, :property)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lings_properties }
    end
  end

  # GET /lings_properties/1
  # GET /lings_properties/1.xml
  def show
    @lings_property = current_group.lings_properties.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lings_property }
    end
  end

  # DELETE /lings_properties/1
  # DELETE /lings_properties/1.xml
  def destroy
    @lings_property = current_group.lings_properties.find(params[:id])
    authorize! :destroy, @lings_property

    @lings_property.destroy

    respond_to do |format|
      format.html { redirect_to(group_lings_properties_url(current_group)) }
      format.xml  { head :ok }
    end
  end
end
