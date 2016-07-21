class ExamplesController < GroupDataController

  respond_to :html, :js

  def index
    @examples = current_group.examples.includes(:group, :ling).paginate(:page => params[:page], :order => "name")

    respond_with(@examples) do |format|
      format.html
      format.json
    end
  end

  def show
    @example = current_group.examples.find(params[:id])

    is_authorized? :read, @example

    respond_with(@example) do |format|
      format.html
      format.json
    end
  end

  def new
    @ling = params[:ling_id] && current_group.lings.find(params[:ling_id])
    @property = params[:prop_id] && current_group.properties.find(params[:prop_id])
    @lp = params[:lp_id] && current_group.lings_properties.find_by_id(params[:lp_id])

    @example = Example.new do |e|
      e.group = current_group
      e.creator = current_user
    end

    is_authorized? :create, @example, true

  end

  def edit
    @example = current_group.examples.find(params[:id])
    @ling = params[:ling_id] ? current_group.lings.find(params[:ling_id]) : @example.ling 
    @property = current_group.properties.find(params[:prop_id]) if params[:prop_id]
    @lp = current_group.lings_properties.find(params[:lp_id]) if params[:lp_id]

    is_authorized? :update, @example, true
  end

  def create
    @example = Example.new(params[:example]) do |example|
      example.group = current_group
      example.creator = current_user
    end

    is_authorized? :create, @example, true

    @example.ling = current_group.lings.find(params[:ling_id]) if params[:ling_id]

    success = @example.save
    if success
      @example.name = "Example_" + @example.id.to_s if @example.name == ""
      @example.save!
      params[:stored_values].each{ |k,v| @example.store_value!(k,v) } if params[:stored_values]

      if params[:lp_val]
        elp = ExamplesLingsProperty.new()
        elp.group = current_group
        elp.lings_property = current_group.lings_properties.find(params[:lp_val])
        elp.example = @example

        is_authorized? :create, elp, true

        success = elp.save
      end
    end

    respond_to do |format|
      if success
        format.html {redirect_to([current_group, @example],
          :notice => (current_group.example_name + ' was successfully created.'))}
        format.json {render json: {success: true}}
      else
        format.json {render json: {success: false}}
      end
    end
  end

  def update
    @example = current_group.examples.find(params[:id])
    is_authorized? :update, @example, true

    respond_to do |format|
      if @example.update_attributes(params[:example])
        params[:stored_values].each{ |k,v| @example.store_value!(k,v) } if params[:stored_values]
        format.html {redirect_to([current_group, @example],
          :notice => (current_group.example_name + ' was successfully updated.'))}
        format.json {render json: {success: true}}
      else
        format.html {render :action => "edit" }
        format.json {render json: {success: false}}
      end
    end
  end

  def destroy
    @example = current_group.examples.find(params[:id])
    is_authorized? :destroy, @example, true

    @example.destroy

    redirect_to(group_examples_url(current_group))
  end

  private

  def get_lings
    { :depth_0 => current_group.lings.at_depth(0),
      :depth_1 => current_group.lings.at_depth(1) }
  end
end
