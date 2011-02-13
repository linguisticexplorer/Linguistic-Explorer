class ExamplesController < ApplicationController

  # GET /examples
  # GET /examples.xml
  def index
    @examples = Example.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @examples }
    end
  end

  # GET /examples/1
  # GET /examples/1.xml
  def show
    @example = Example.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @example }
    end
  end

  # GET /examples/new
  # GET /examples/new.xml
  def new
    @example = Example.new
    @lings = {
          :depth_0 => Ling.find_all_by_depth(0),
          :depth_1 => Ling.find_all_by_depth(1)
    }

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => [@example, @lings] }
    end
  end

  # GET /examples/1/edit
  def edit
    @example = Example.find(params[:id])
    @lings = {
          :depth_0 => Ling.find_all_by_depth(0),
          :depth_1 => Ling.find_all_by_depth(1)
    }
  end

  # POST /examples
  # POST /examples.xml
  def create
    @example = Example.new(params[:example])

    respond_to do |format|
      if @example.save
        format.html { redirect_to(@example, :notice => 'Example was successfully created.') }
        format.xml  { render :xml => @example, :status => :created, :location => @example }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @example.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /examples/1
  # PUT /examples/1.xml
  def update
    @example = Example.find(params[:id])

    respond_to do |format|
      if @example.update_attributes(params[:example])
        format.html { redirect_to(@example, :notice => 'Example was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @example.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /examples/1
  # DELETE /examples/1.xml
  def destroy
    @example = Example.find(params[:id])
    @example.destroy

    respond_to do |format|
      format.html { redirect_to(examples_url) }
      format.xml  { head :ok }
    end
  end
end
