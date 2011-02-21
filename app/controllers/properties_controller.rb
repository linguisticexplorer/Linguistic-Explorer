class PropertiesController < ApplicationController
  before_filter :load_group_from_params

  # GET /properties
  # GET /properties.xml
  def index
    @properties = Property.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @properties }
    end
  end

  # GET /properties/1
  # GET /properties/1.xml
  def show
    @property = Property.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @property }
    end
  end

  # GET /properties/new
  # GET /properties/new.xml
  def new
    @property = Property.new
    @categories = {
          :depth_0 => Property.find_all_by_depth(0).map(&:category).uniq.sort,
          :depth_1 => Property.find_all_by_depth(1).map(&:category).uniq.sort
    }

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => [@property, @categories] }
    end
  end

  # GET /properties/1/edit
  def edit
    @property = Property.find(params[:id])
    @categories = {
          :depth_0 => Property.find_all_by_depth(0).map(&:category).uniq.sort,
          :depth_1 => Property.find_all_by_depth(1).map(&:category).uniq.sort
    }
  end

  # POST /properties
  # POST /properties.xml
  def create
    @property = Property.new(params[:property].merge({:group_id => @group.id}))

    respond_to do |format|
      if @property.save
        format.html { redirect_to(group_property_url(@group, @property), :notice => 'Property was successfully created.') }
        format.xml  { render :xml => @property, :status => :created, :location => @property }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @property.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /properties/1
  # PUT /properties/1.xml
  def update
    @property = Property.find(params[:id])

    respond_to do |format|
      if @property.update_attributes(params[:property])
        format.html { redirect_to(group_property_url(@group, @property), :notice => 'Property was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @property.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /properties/1
  # DELETE /properties/1.xml
  def destroy
    @property = Property.find(params[:id])
    @property.destroy

    respond_to do |format|
      format.html { redirect_to(group_properties_url(@group)) }
      format.xml  { head :ok }
    end
  end
end
