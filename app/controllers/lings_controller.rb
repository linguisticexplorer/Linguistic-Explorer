class LingsController < GroupDataController
  helper :groups

  respond_to :html, :js

  def depth
    @depth = params[:depth].to_i
    @all_lings = current_group.lings.at_depth(@depth)
    @lings, @params = @all_lings.alpha_paginate(params[:letter], {db_mode: true, db_field: "name", default_field: "a", numbers: false})
    return load_stats(@lings, params[:plain], 0)
  end
 
  def dict
    @all_lings = Hash.new
    if (params[:depth] || params[:id])
      current_group.lings.at_depth(params[:depth] || Ling.find(params[:id]).depth).find_each(:batch_size => 500) do |ling| 
        @all_lings[ling.name] = ling.id
      end
    else
      current_group.lings.find_each(:batch_size => 500) do |ling| 
        @all_lings[ling.name] = ling.id
      end
    end
    render :json => @all_lings.to_json.html_safe
  end

  def dict1
    @all_lings = Hash.new
    current_group.lings.find_each(:batch_size => 500) do |ling| 
      @all_lings[ling.name] = ling.id
    end
    render :json => @all_lings.to_json.html_safe
  end

  def index
    @lings_by_depth = current_group.depths.collect do |depth|
      current_group.lings.at_depth(depth).
        alpha_paginate(params[:letter], {db_mode: true, db_field: "name", default_field: "a", numbers: false})
    end
    return load_stats(@lings_by_depth, params[:plain], 1)
  end

  def show
    @ling = current_group.lings.find(params[:id])
    @values = @ling.lings_properties.order(:property_id).paginate(:page => params[:page])

    respond_with(@values) do |format|
      format.html
      format.js
    end
  end

  def supported_set_values
    @ling = current_group.lings.find(params[:id])
    @depth = @ling.depth
    @categories = current_group.categories.at_depth(@depth)
    session[:category_id] = params[:category_id] if params[:category_id]
    @category = session[:category_id] ? Category.find(session[:category_id]) : @categories.first
    @properties = @category.properties.order('name')
    @preexisting_values = @ling.lings_properties.select {|lp| @properties.map{|prop| prop.id }.include? lp.property_id}
    @exists = true
    if params[:prop_id]
      session[:prop_id] ||= params[:prop_id] if params[:prop_id]
      if params[:commit] == "Select"
        session[:prop_id] = params[:prop_id] if params[:prop_id]
      else
        pos = @properties.map(&:id).index(session[:prop_id].to_i) + 1
        search_space = @properties[pos, @properties.length] + @properties[0,pos]
        if params[:commit] == "Next"
            session[:prop_id] = search_space.first.id
        elsif params[:commit] == "Next Unset"
          unset_space = @preexisting_values.map(&:property_id)
          unset_search_space = search_space.reject{|prop| unset_space.include? prop.id}
          session[:prop_id] = unset_search_space.any? ? unset_search_space.first.id : session[:prop_id]
        elsif params[:commit] == "Next Uncertain"
          uncertain_space = @preexisting_values.select{|lp| lp.sureness == "revisit" || lp.sureness == "need_help"}.map(&:property_id)
          uncertain_search_space = search_space.select{|prop| uncertain_space.include? prop.id}
          session[:prop_id] = uncertain_search_space.any? ? uncertain_search_space.first.id : session[:prop_id]
        end
      end
    end
    if session[:prop_id]
      @ling_properties = @preexisting_values.select {|lp| lp.property_id == session[:prop_id].to_i} if @preexisting_values.any?
      @property = Property.find(session[:prop_id])
      @exists = false if @ling_properties.nil? or @ling_properties.empty?
    elsif @preexisting_values.length > 0
      @property = Property.find(@preexisting_values.first.property_id)
      @ling_properties = @preexisting_values.select {|lp| lp.property_id == @property.id}
    else 
      @property = Property.find(@properties.first)
      @exists = false
    end
    @examples = []
    if @exists
      @ling_properties.each {|lp| @examples += lp.examples if !lp.examples.empty?}
      @example =  params[:example_id] ? Example.find(params[:example_id]) : (@examples.length > 0 && @examples.first) || nil
    end
    @relations = []
    @property.lings_properties.includes(:ling).find_each(:batch_size => 500) do |lp|
      @relations << [lp.ling.name, lp.value]
    end
    @relations.sort{|x,y| x[0] <=> y[0]}

    # authorize! :update, @ling
  end

  def supported_submit_values
    @ling = current_group.lings.find(params[:id])
    fresh_vals = LingsProperty.find(:all,
                                :conditions => {ling_id: @ling.id, property_id: params[:property_id]})
    if fresh_vals.count > 1
      fresh_vals.each do |val|
        val.delete
      end
    elsif fresh_vals.count == 1
      fresh = fresh_vals[0]
    end


    authorize! :manage, fresh if fresh

    prop_id = params[:property_id]
    prop_value = params[:value] == "value_new" ? params[:new_value] : params[:value]
    property = current_group.properties.find(prop_id)

    if fresh
      fresh.value = prop_value
      fresh.sureness = params[:value_sureness] if params[:value_sureness]
    else
      fresh = LingsProperty.new do |lp|
        lp.ling  = @ling
        lp.group = current_group
        lp.property = property
        lp.value = prop_value
        lp.sureness = params[:value_sureness] if params[:value_sureness]
      end
    end

    authorize! :create, fresh

    respond_to do |format|
      if fresh.save!
        format.html {redirect_to supported_set_values_group_ling_path(current_group, @ling)}
        format.json {render json: {success: true, id: prop_id}}
      else
        format.html {redirect_to supported_set_values_group_ling_path(current_group, @ling)}
        format.json {render json: {success: false}}
      end
    end
  end

  def supported_submit_values_multiple
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

    respond_to do |format|
      format.html {redirect_to supported_set_values_group_ling_path(current_group, @ling)}
      format.json {render json: {success: true}}
    end
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
      lings.each do |lings_with_params|
        # If it is a multilanguage group map each subling
         if depth > 0
          lings_with_params.first.map { |ling_at_depth| load_infos(ling_at_depth) }
         else
        # otherwise map just the ling
          load_infos(lings_with_params)
         end
      end
    end
    lings
  end

  def load_infos(ling)
    ling.get_infos
  end

end
