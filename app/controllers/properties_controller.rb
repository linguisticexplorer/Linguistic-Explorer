class PropertiesController < GroupDataController

  respond_to :html, :js

  def index
    # Added Eager Loading
    @properties = current_group.properties.includes(:category).paginate(:page => params[:page], :order =>"name")
    @properties.map { |prop| prop.get_infos } unless params[:plain]
    
    @hasCategories = current_group.categories.count > 0
    respond_with(@properties) do |format|
      format.html
      format.js
    end
  end

  def list
    @property = Property.new do |p|
      p.group = current_group
      p.creator = current_user
    end

    is_authorized? :read, @property

    render :json => current_group.properties.to_json
  end

  def show
    @depth = params[:depth].to_i
    @property = current_group.properties.find(params[:id])

    is_authorized? :read, @property

    # Filter the number of lings to show based on the pagination
    lings = current_group.lings.at_depth(@depth)
    # Now get the values of the filtered lings
    lings_ids = [lings].flatten.map(&:id)
    @values = @property.lings_properties.includes(:ling).where(:ling_id => lings_ids)
    # Workout the total number of values set for this property
    @values_count = @property.lings_properties.count(:id)

    @property.get_infos



    require 'redcarpet'
    options = {
      filter_html:     true,
      hard_wrap:       true,
      link_attributes: {
        rel: 'nofollow',
        target: "_blank"
      },
      space_after_headers: true,
      fenced_code_blocks: true
    }

    extensions = {
      autolink:           true,
      superscript:        true,
      disable_indented_code_blocks: true,
      tables: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)




    if @property.description.present? && @property.description != ""
      @output = markdown.render(@property.description)
      @output = @output.gsub("<em>","<em style='font-style: italic;'>").gsub(/<br>\s*<br>/,'<br>').gsub("<ol>","<ol style=\"list-style-type: decimal; padding-left: 40px;\">")
      @output = @output.gsub("<table>","<table style='border-spacing: 10px; border-collapse: separate;'>").gsub("<thead>",'<thead style="font-weight: bold;">').html_safe
    end


    respond_with(@values) do |format|
      format.html
      format.js
    end
    
  end

  def new
    @property = Property.new do |p|
      p.group = current_group
      p.creator = current_user
    end
    is_authorized? :create, @property

    @categories = get_categories
  end

  def edit
    @property = current_group.properties.find(params[:id])
    is_authorized? :update, @property




require 'redcarpet'
    options = {
      filter_html:     true,
      hard_wrap:       true,
      link_attributes: {
        rel: 'nofollow',
        target: "_blank"
      },
      space_after_headers: true,
      fenced_code_blocks: true
    }

    extensions = {
      autolink:           true,
      superscript:        true,
      disable_indented_code_blocks: true,
      tables: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)
    

    if @property.description.present? && @property.description != ""
      @output = markdown.render(@property.description).html_safe
    end




    @categories = get_categories
  end

  def create
    @property = Property.new(params[:property]) do |property|
      property.group = current_group
      property.creator = current_user
    end
    is_authorized? :create, @property

    if @property.save
      redirect_to([current_group, @property],
                  :notice => (current_group.property_name + ' was successfully created.'))
    else
      @categories = get_categories
      render :action => "new"
    end
  end

  def update
    @property = current_group.properties.find(params[:id])
    is_authorized? :update, @property

    if @property.update_attributes(params[:property])
      redirect_to([current_group, @property],
                  :notice => (current_group.property_name + ' was successfully updated.'))
    else
      @categories = get_categories
      render :action => "edit"
    end
  end

  def destroy
    @property = current_group.properties.find(params[:id])
    is_authorized? :destroy, @property

    @property.destroy

    redirect_to(group_properties_url(current_group))
  end

  private

  def get_categories
    {:depth_0 => current_group.categories.at_depth(0),
     :depth_1 => current_group.categories.at_depth(1) }
  end
end
