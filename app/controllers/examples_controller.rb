class ExamplesController < GroupDataController

  respond_to :html, :js

  def index
    @examples = current_group.examples.includes(:group, :ling).paginate(:page => params[:page], :order => "name")

    respond_with(@examples) do |format|
      format.html
      format.js
    end
  end

  def show
    @example = current_group.examples.find(params[:id])

    respond_with(@example) do |format|
      format.html
      format.js
    end
  end

  def new
    @ling = params[:ling_id] && Ling.find(params[:ling_id])
    @property = params[:prop_id] && Property.find(params[:prop_id])
    @lp = params[:lp_id] && LingsProperty.find_by_id(params[:lp_id])
    @example = Example.new do |e|
      e.group = current_group
      e.creator = current_user
    end
    authorize! :create, @example

  end

  def edit
    @example = current_group.examples.find(params[:id])
    @ling = Ling.find(params[:ling_id]) if params[:ling_id]
    @property = Property.find(params[:prop_id]) if params[:prop_id]
    @lp = LingsProperty.find(params[:lp_id]) if params[:lp_id]
    authorize! :update, @example

    @lings = get_lings
  end

  def create
    @example = Example.new(params[:example]) do |example|
      example.group = current_group
      example.creator = current_user
    end

    authorize! :create, @example

    if params[:lp_val]
      elp = ExamplesLingsProperty.new()
      elp.group = current_group
      elp.lings_property = LingsProperty.find(params[:lp_val])
      elp.example = @example

      authorize! :create, elp
    end

    respond_to do |format|
      if @example.save && (params[:lp_val] && elp.save || true)
        @example.name = "Example_" + @example.id.to_s if @example.name == ""
        @example.save!
        params[:stored_values].each{ |k,v| @example.store_value!(k,v) } if params[:stored_values]
        
        format.html {redirect_to([current_group, @example],
                      :notice => (current_group.example_name + ' was successfully created.'))}
        format.json {render json: {success: true}}
      else
        @format.html do 
          @lings = get_lings
          render :action => "new"
        end
        format.json {render json: {success: false}}
      end
    end
  end

  def update
    @example = current_group.examples.find(params[:id])
    authorize! :update, @example

    respond_to do |format|
      if @example.update_attributes(params[:example])
        params[:stored_values].each{ |k,v| @example.store_value!(k,v) } if params[:stored_values]
        format.html{ redirect_to([current_group, @example],
                  :notice => (current_group.example_name + ' was successfully updated.'))}
        format.json {render json: {success: true}}
      else
        @format.html do 
          @lings = get_lings
          render :action => "edit"
        end
        format.json {render json: {success: false}}
      end
    end
  end

  def destroy
    @example = current_group.examples.find(params[:id])
    authorize! :destroy, @example

    @example.destroy

    redirect_to(group_examples_url(current_group))
  end

  private

  def get_lings
    { :depth_0 => current_group.lings.at_depth(0),
      :depth_1 => current_group.lings.at_depth(1) }
  end
end
