class ExamplesController < GroupDataController
  def index
    @examples = current_group.examples.includes(:group, :ling)
  end

  def show
    @example = current_group.examples.find(params[:id])
  end

  def new
    @example = Example.new do |e|
      e.group = current_group
      e.creator = current_user
    end
    authorize! :create, @example

    @lings = {
          :depth_0 => current_group.lings.at_depth(0),
          :depth_1 => current_group.lings.at_depth(1)
    }
  end

  def edit
    @example = current_group.examples.find(params[:id])
    authorize! :update, @example

    @lings = {
          :depth_0 => current_group.lings.at_depth(0),
          :depth_1 => current_group.lings.at_depth(1)
    }
  end

  def create
    @example = Example.new(params[:example]) do |example|
      example.group = current_group
      example.creator = current_user
    end
    authorize! :create, @example

    if @example.save
      params[:stored_values].each{ |k,v| @example.store_value!(k,v) } if params[:stored_values]
      redirect_to([current_group, @example], :notice => (current_group.example_name + ' was successfully created.'))
    else
      @lings = {
            :depth_0 => current_group.lings.at_depth(0),
            :depth_1 => current_group.lings.at_depth(1)
      }
      render :action => "new"
    end
  end

  def update
    @example = current_group.examples.find(params[:id])
    authorize! :update, @example

    if @example.update_attributes(params[:example])
      params[:stored_values].each{ |k,v| @example.store_value!(k,v) } if params[:stored_values]
      redirect_to([current_group, @example], :notice => (current_group.example_name + ' was successfully updated.'))
    else
      @lings = {
            :depth_0 => current_group.lings.at_depth(0),
            :depth_1 => current_group.lings.at_depth(1)
      }
      render :action => "edit"
    end
  end

  def destroy
    @example = current_group.examples.find(params[:id])
    authorize! :destroy, @example

    @example.destroy

    redirect_to(group_examples_url(current_group))
  end
end
