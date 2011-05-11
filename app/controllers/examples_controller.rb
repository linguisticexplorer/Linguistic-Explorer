class ExamplesController < GroupDataController

  # GET /examples
  # GET /examples.xml
  def index
    @examples = current_group.examples.includes(:group, :ling)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @examples }
    end
  end

  # GET /examples/1
  # GET /examples/1.xml
  def show
    @example = current_group.examples.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @example }
    end
  end

  # GET /examples/new
  # GET /examples/new.xml
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

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => [@example, @lings] }
    end
  end

  # GET /examples/1/edit
  def edit
    @example = current_group.examples.find(params[:id])
    authorize! :update, @example

    @lings = {
          :depth_0 => current_group.lings.at_depth(0),
          :depth_1 => current_group.lings.at_depth(1)
    }
  end

  # POST /examples
  # POST /examples.xml
  def create
    @example = Example.new(params[:example]) do |example|
      example.group = current_group
      example.creator = current_user
    end

    authorize! :create, @example

    respond_to do |format|
      if @example.save
        params[:stored_values].each{ |k,v| @example.store_value!(k,v) } if params[:stored_values]
        format.html { redirect_to([current_group, @example], :notice => (current_group.example_name + ' was successfully created.')) }
        format.xml  { render :xml => @example, :status => :created, :location => @example }
      else
        @lings = {
              :depth_0 => current_group.lings.at_depth(0),
              :depth_1 => current_group.lings.at_depth(1)
        }
        format.html { render :action => "new" }
        format.xml  { render :xml => @example.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /examples/1
  # PUT /examples/1.xml
  def update
    @example = current_group.examples.find(params[:id])
    authorize! :update, @example

    respond_to do |format|
      if @example.update_attributes(params[:example])
        params[:stored_values].each{ |k,v| @example.store_value!(k,v) } if params[:stored_values]
        format.html { redirect_to([current_group, @example], :notice => (current_group.example_name + ' was successfully updated.')) }
        format.xml  { head :ok }
      else
        @lings = {
              :depth_0 => current_group.lings.at_depth(0),
              :depth_1 => current_group.lings.at_depth(1)
        }
        format.html { render :action => "edit" }
        format.xml  { render :xml => @example.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /examples/1
  # DELETE /examples/1.xml
  def destroy
    @example = current_group.examples.find(params[:id])
    authorize! :destroy, @example

    @example.destroy

    respond_to do |format|
      format.html { redirect_to(group_examples_url(current_group)) }
      format.xml  { head :ok }
    end
  end
end
