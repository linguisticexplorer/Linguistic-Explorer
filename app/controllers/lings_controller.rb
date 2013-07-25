class LingsController < GroupDataController
  helper :groups

  def depth
    @depth = params[:depth].to_i
    @all_lings = current_group.lings.at_depth(@depth)
    @lings, @params = @all_lings.alpha_paginate(params[:letter], {db_mode: true, db_field: "name"})
    return load_stats(@lings, params[:plain], 0)
  end

  def index
    @lings_by_depth = current_group.depths.collect do |depth|
      current_group.lings.at_depth(depth).paginate(:page => params[:page])
    end
    return load_stats(@lings_by_depth, params[:plain], 1)
    # return load_statedit
    # @ling = current_group.lings.find(params[:id])
    # @depth = @ling.depth

    # authorize! :update, @ling

    # @parents = @depth ? current_group.lings.at_depth(@depth - 1) : []
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
    session[:category_id] = params[:category_id] if params[:category_id]
    @category = session[:category_id] ? Category.find(session[:category_id]) : @categories[0] 
    @properties = @category.properties.order('name')
    @preexisting_values = @ling.lings_properties.select {|lp| @properties.map{|prop| prop.id }.include? lp.property_id}
    @exists = true
    if params[:prop_id]
      if params[:commit] == "Select"
        session[:prop_id] = params[:prop_id] if params[:prop_id]
      else
        pos = @properties.map(&:id).index(params[:prop_id].to_i) + 1
        search_space = @properties[pos, @properties.length] + @properties[0,pos]
        if params[:commit] == "Next"
          session[:prop_id] = search_space[0].id
        elsif params[:commit] == "Next Unset"
          unset_space = @preexisting_values.map(&:property_id)
          unset_search_space = search_space.reject{|prop| unset_space.include? prop.id}
          session[:prop_id] = unset_search_space.any? ? unset_search_space[0].id : params[:prop_id]
        elsif params[:commit] == "Next Uncertain"
          uncertain_space = @preexisting_values.select{|lp| lp.sureness == "revisit" || lp.sureness == "need_help"}.map(&:property_id)
          uncertain_search_space = search_space.select{|prop| uncertain_space.include? prop.id}
          session[:prop_id] = uncertain_search_space.any? ? uncertain_search_space[0].id : params[:prop_id]
        end
      end
    end
    if session[:prop_id]
      @ling_properties = @preexisting_values.select {|lp| lp.property_id == session[:prop_id].to_i} if @preexisting_values.any?
      @property = Property.find(session[:prop_id])
      @exists = false if @ling_properties.nil?
    elsif @preexisting_values.length > 0
      @property = Property.find(@preexisting_values[0].property_id)
      @ling_properties = @preexisting_values.select {|lp| lp.property_id == @property.id}
    else 
      @property = Property.find(@properties[0])
      @exists = false
    end
    if @exists
      @examples = []
      @ling_properties.each {|lp| @examples += lp.examples if !lp.examples.empty?}
      @example =  params[:example_id] ? Example.find(params[:example_id]) : (@examples.length > 0 && @examples[0]) || nil
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
          lp.sureness = params[:value_sureness]
        end
        fresh.sureness = params[:value_sureness] if fresh.sureness != params[:value_sureness]
        fresh_values << fresh
      end

      prop_values.each do |value, flag|
        fresh = LingsProperty.find_by_ling_id_and_property_id_and_value(@ling.id, property.id, value)
        fresh ||= LingsProperty.new do |lp|
          lp.ling  = @ling
          lp.group = current_group
          lp.property = property
          lp.value = value
          lp.sureness = params[:value_sureness]
        end
        fresh.sureness = params[:value_sureness] if fresh.sureness != params[:value_sureness]
        fresh_values << fresh
      end
    end

    collection_authorize! :create, fresh_values

    fresh_values.each{ |fresh| fresh.save }
    stale_values.each{ |stale| stale.delete unless fresh_values.include?(stale) }

    redirect_to set_values_group_ling_path(current_group, @ling)
  end

  def supported_submit_values
    @ling = current_group.lings.find(params[:id])
    stale_values = @ling.lings_properties.find(:all, conditions: {property_id: params[:property_id]})

    collection_authorize! :manage, stale_values if stale_values

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
          lp.sureness = params[:value_sureness]
        end
        fresh.sureness = params[:value_sureness] if fresh.sureness != params[:value_sureness]
        fresh_values << fresh
      end

      prop_values.each do |value, flag|
        fresh = LingsProperty.find_by_ling_id_and_property_id_and_value(@ling.id, property.id, value)
        fresh ||= LingsProperty.new do |lp|
          lp.ling  = @ling
          lp.group = current_group
          lp.property = property
          lp.value = value
          lp.sureness = params[:value_sureness]
        end
        fresh.sureness = params[:value_sureness] if fresh.sureness != params[:value_sureness]
        fresh_values << fresh
      end
    end

    collection_authorize! :create, fresh_values

    fresh_values.each{ |fresh| fresh.save}
    stale_values.each{ |stale| stale.delete unless fresh_values.include?(stale) } if stale_values

    redirect_to supported_set_values_group_ling_path(current_group, @ling)
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
        # If it is a multilanguage group map each subling
         if depth > 0
          ling.map { |ling_at_depth| load_infos(ling_at_depth) }
         else
        # otherwise map just the ling
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
