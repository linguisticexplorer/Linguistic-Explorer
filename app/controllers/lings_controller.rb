class LingsController < GroupDataController
  helper :groups

  def depth
    @depth = params[:depth].to_i
    @lings = current_group.lings.at_depth(@depth).paginate(:page => params[:page], :order => "name")
    return load_stats(@lings, params[:plain], 0)
  end

  def index
    @lings_by_depth = current_group.depths.collect do |depth|
      current_group.lings.at_depth(depth).paginate(:page => params[:page])
    end
    return load_statedit
    @ling = current_group.lings.find(params[:id])
    @depth = @ling.depth

    authorize! :update, @ling

    @parents = @depth ? current_group.lings.at_depth(@depth - 1) : []
  end

  def show
    @ling = current_group.lings.find(params[:id])
    @values = @ling.lings_properties.order(:property_id).paginate(:page => params[:page])
  end

  def set_values
    @ling = current_group.lings.find(params[:id])
    @depth = @ling.depth
    @categories = current_group.categories.at_depth(@depth)
    @preexisting_values = @ling.lings_properties

    # authorize! :update, @ling
  end
  
  def supported_set_values
    @ling = current_group.lings.find(params[:id])
    @depth = @ling.depth
    @categories = current_group.categories.at_depth(@depth)
    if params[:category_id]
      @category = Category.find(params[:category_id]) 
    else
      @category = @categories[0]
    end
    @preexisting_values = @ling.lings_properties.reject {|lp| !@category.properties.include? lp.property}
    @exists = true
    if params[:prop_id]
      @ling_properties = @preexisting_values.select {|lp| lp.property_id == params[:prop_id]} if @preexisting_values
      @property = Property.find(params[:prop_id])
      @exists = false if !@ling_property
    elsif @preexisting_values.length > 0
      @property = Property.find(@preexisting_values[0].property_id)
      @ling_properties = @preexisting_values.select {|lp| lp.property_id == @property.id}
    else 
      @property = Property.find(@category.properties[0])
      @exists = false
    if @exists
      @examples = @ling_property.examples
    end
    end

    # authorize! :update, @ling
  end

  def submit_values
    @ling = current_group.lings.find(params[:id])
    stale_values = @ling.lings_properties

    collection_authorize! :manage, stale_values

    fresh_values = []
    values = params.delete(:values) || []
    values.each do |prop_id, prop_values|
      property = current_group.properties.find(prop_id)

      new_text = prop_values.delete("_new")
      if !(new_text.blank?)
        fresh = LingsProperty.find_by_ling_id_and_property_id_and_value(@ling.id, property.id, new_text)
        fresh ||= LingsProperty.new do |lp|
          lp.ling  = @ling
          lp.group = current_group
          lp.property = property
          lp.value = new_text
        end
        fresh_values << fresh
      end

      prop_values.each do |value, flag|
        fresh = LingsProperty.find_by_ling_id_and_property_id_and_value(@ling.id, property.id, value)
        fresh ||= LingsProperty.new do |lp|
          lp.ling  = @ling
          lp.group = current_group
          lp.property = property
          lp.value = value
        end
        fresh_values << fresh
      end
    end

    collection_authorize! :create, fresh_values

    fresh_values.each{ |fresh| fresh.save }
    stale_values.each{ |stale| stale.delete unless fresh_values.include?(stale) }

    redirect_to supported_set_values_group_ling_path(current_group, @ling)
  end

  def supported_submit_values
    @ling = current_group.lings.find(params[:id])
    stale_values = @ling.lings_properties

    collection_authorize! :manage, stale_values

    fresh_values = []
    values = params.delete(:values) || []
    values.each do |prop_id, prop_values|
      property = current_group.properties.find(prop_id)

      new_text = prop_values.delete("_new")
      if !(new_text.blank?)
        fresh = LingsProperty.find_by_ling_id_and_property_id_and_value(@ling.id, property.id, new_text)
        fresh ||= LingsProperty.new do |lp|
          lp.ling  = @ling
          lp.group = current_group
          lp.property = property
          lp.value = new_text
        end
        fresh_values << fresh
      end

      prop_values.each do |value, flag|
        fresh = LingsProperty.find_by_ling_id_and_property_id_and_value(@ling.id, property.id, value)
        fresh ||= LingsProperty.new do |lp|
          lp.ling  = @ling
          lp.group = current_group
          lp.property = property
          lp.value = value
        end
        fresh_values << fresh
      end
    end

    collection_authorize! :create, fresh_values

    fresh_values.each{ |fresh| fresh.save }
    stale_values.each{ |stale| stale.delete unless fresh_values.include?(stale) }

    redirect_to set_values_group_ling_path(current_group, @ling)
  end

  def new
    @depth = params[:depth].to_i
    @parents = (@depth && @depth > 0 ? current_group.lings.at_depth(@depth - 1) : [])
    @ling = Ling.new do |l|
      l.depth = @depth
      l.creator = current_user
      l.group = current_group
    end

    authorize! :create, @ling
  end

  def edit
    @ling = current_group.lings.find(params[:id])
    @depth = @ling.depth

    authorize! :update, @ling

    @parents = @depth ? current_group.lings.at_depth(@depth - 1) : []
  end


  def create
    @ling = Ling.new(params[:ling]) do |ling|
      ling.group    = current_group
      ling.creator  = current_user
      ling.depth    = params[:ling][:depth].to_i
    end
    @depth = @ling.depth

    authorize! :create, @ling

    if @ling.save
      params[:stored_values].each{ |k,v| @ling.store_value!(k,v) } if params[:stored_values]
      redirect_to([current_group, @ling],
                  :notice => (current_group.ling_name_for_depth(@depth) + ' was successfully created.'))
    else
      @parents = @depth ? Ling.find_all_by_depth(@depth - 1) : []
      render :action => "new"
    end
  end

  def update
    @ling = current_group.lings.find(params[:id])
    @depth = @ling.depth

    authorize! :update, @ling

    if @ling.update_attributes(params[:ling])
      params[:stored_values].each{ |k,v| @ling.store_value!(k,v) } if params[:stored_values]
      redirect_to(group_ling_url(current_group, @ling),
                  :notice => (current_group.ling_name_for_depth(@depth) + ' was successfully updated.') )
    else
      @parents = @depth ? Ling.find_all_by_depth(@depth - 1) : []
      render :action => "edit"
    end
  end

  def destroy
    @ling = current_group.lings.find(params[:id])
    @depth = @ling.depth

    authorize! :destroy, @ling
    @ling.destroy

    redirect_to(group_lings_depth_url(current_group, @depth))
  end

  private
  def load_stats(lings, plain, depth)
    unless plain
      lings.each do |ling|
        # If it is a multilanguage group map each subling otherwise map just the ling
         if depth > 0
          ling.map { |ling_at_depth| load_infos(ling_at_depth) }
        else
          load_infos(ling)
        end
      end
    end
    lings
  end

  def load_infos(ling)
    ling.get_infos
  end
end
