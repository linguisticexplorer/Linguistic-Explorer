class ExamplesLingsPropertiesController < GroupDataController

  respond_to :html, :js

  def show
    @examples_lings_property = current_group.examples_lings_properties.find(params[:id])

    respond_with(@examples_lings_property) do |format|
      format.html
      format.js
    end
  end

  def new
    @examples_lings_property = ExamplesLingsProperty.new do |elp|
      elp.group = current_group
      elp.creator = current_user
    end
    is_authorized? :create, @examples_lings_property, true

    @examples = current_group.examples
    @lings_properties = current_group.lings_properties.includes(:property, :ling).sort_by(&:description)

    if(params[:ling_id])
      lps_by_lings = LingsProperty.where(:ling_id => params[:ling_id])

      @examples = ExamplesLingsProperty.where(:lings_property_id => lps_by_lings).map{ |x| x.example } || @examples

      @lings_properties = false
    end
  end

  def create
    @examples_lings_property = ExamplesLingsProperty.new(params[:examples_lings_property]) do |elp|
      elp.group = current_group
      elp.creator = current_user
    end
    is_authorized? :create, @examples_lings_property, true

    respond_to do |format|
      if @examples_lings_property.save
        format.html {redirect_to([current_group, @examples_lings_property], :notice => (current_group.examples_lings_property_name + ' was successfully created.'))}
        format.json {render json: {success: true}}
      else
        format.html do
          @examples = current_group.examples
          @lings_properties = current_group.lings_properties
          render :action => "new"
        end
        format.json {render json: {success: false}}
      end
    end
  end

  def destroy
    @examples_lings_property = ExamplesLingsProperty.find(params[:id])
    @examples_lings_property = current_group.examples_lings_properties.find(params[:id])

    is_authorized? :destroy, @examples_lings_property, true
    @examples_lings_property.destroy

    redirect_to(current_group)
  end
end
