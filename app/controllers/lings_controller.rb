class LingsController < GroupDataController
  helper :groups

  # GET /lings/depth/0-1
  # GET /lings/depth/0-1.xml
  def depth
    @depth = params[:depth].to_i
    @lings = Ling.find_all_by_depth(@depth)
    authorize! :read, @lings

    respond_to do |format|
      format.html # depth.html.erb
      format.xml  { render :xml => [@lings, @depth] }
    end
  end

  # GET /lings
  # GET /lings.xml
  def index
    @lings_by_depth = (0..current_group.depth_maximum).to_a.map{|depth| Ling.find_all_by_depth(depth)}

    authorize! :read, @lings_by_depth
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lings_by_depth }
    end
  end

  # GET /lings/1
  # GET /lings/1.xml
  def show
    @ling = Ling.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ling }
    end
  end

  # GET /lings/1/set_values
  def set_values
    @ling = Ling.find(params[:id])
    @depth = @ling.depth
    @categories = Category.at_depth(@depth)
    @preexisting_values = LingsProperty.find_all_by_ling_id(@ling.id)
  end

  # POST /lings/1/submit_values
  def submit_values
    @ling = Ling.find(params[:id])
    stale_values = @ling.lings_properties

    fresh_values = []
    values = params.delete(:values) || []
    values.each do |prop_id, prop_values|
      property = Property.find(prop_id)

      new_text = prop_values.delete("_new")
      if !(new_text.blank?)
        fresh = LingsProperty.find_by_group_id_and_ling_id_and_property_id_and_value(current_group.id, @ling.id, property.id, new_text)
        fresh ||= LingsProperty.new do |lp|
          lp.ling  = @ling
          lp.group = current_group
          lp.value = new_text
          lp.property = property
        end
        fresh_values << fresh if fresh.save
      end

      prop_values.each do |value, flag|
        fresh = LingsProperty.find_by_group_id_and_ling_id_and_property_id_and_value(current_group.id, @ling.id, property.id, value)
        fresh ||= LingsProperty.new do |lp|
          lp.ling  = @ling
          lp.group = current_group
          lp.value = value
          lp.property = property
        end
        fresh_values << fresh if fresh.save
      end
    end
    stale_values.each{ |stale| stale.delete unless fresh_values.include? stale }

    redirect_to set_values_group_ling_path(current_group, @ling)
  end

  # GET /lings/new
  # GET /lings/new?depth=0-1
  # GET /lings/new.xml
  def new
    @depth = params[:depth].to_i
    @ling = Ling.new{ |l| l.depth = @depth }
    @parents = @depth ? Ling.find_all_by_depth(@depth - 1) : []

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => [@ling, @lings] }
    end
  end

  # GET /lings/1/edit
  def edit
    @ling = Ling.find(params[:id])
    @depth = @ling.depth
    @parents = @depth ? Ling.find_all_by_depth(@depth - 1) : []
  end

  # POST /lings
  # POST /lings.xml
  def create
    @ling = Ling.new(params[:ling]) do |ling|
      ling.group    = current_group
      ling.creator  = current_user
      ling.depth    = params[:ling][:depth].to_i
    end
    @depth = @ling.depth

    respond_to do |format|
      if @ling.save
        format.html { redirect_to([current_group, @ling], :notice => (current_group.ling_name_for_depth(@depth) + ' was successfully created.')) }
        format.xml  { render :xml => @ling, :status => :created, :location => @ling }
      else
        @parents = @depth ? Ling.find_all_by_depth(@depth - 1) : []
        format.html { render :action => "new" }
        format.xml  { render :xml => @ling.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /lings/1
  # PUT /lings/1.xml
  def update
    @ling = Ling.find(params[:id])
    @depth = @ling.depth

    respond_to do |format|
      if @ling.update_attributes(params[:ling])
        format.html { redirect_to(group_ling_url(current_group, @ling), :notice => (current_group.ling_name_for_depth(@depth) + ' was successfully updated.') ) }
        format.xml  { head :ok }
      else
        @parents = @depth ? Ling.find_all_by_depth(@depth - 1) : []
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ling.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /lings/1
  # DELETE /lings/1.xml
  def destroy
    @ling = Ling.find(params[:id])
    @depth = @ling.depth
    @ling.destroy

    respond_to do |format|
      format.html { redirect_to(group_lings_depth_url(current_group, @depth)) }
      format.xml  { head :ok }
    end
  end
end
