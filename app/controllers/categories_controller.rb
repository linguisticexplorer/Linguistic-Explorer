class CategoriesController < GroupDataController

  respond_to :html, :js
  
  def index
    @categories = current_group.categories.paginate(:page => params[:page], :order => "name")

    respond_with(@categories) do |format|
      format.html
      format.js
    end
  end

  def show
    @category = current_group.categories.find(params[:id])

    is_authorized? :read, @category
    
    @properties = current_group.properties.where(:category_id => @category.id).count(:id)

    respond_with(@category) do |format|
      format.html
      format.js
    end
  end

  def new
    @depth = params[:depth].to_i

    @category = Category.new do |c|
      c.group = current_group
      c.creator = current_user
      c.depth = @depth
    end

    is_authorized? :create, @category
  end

  def edit
    @category = current_group.categories.find(params[:id])

    is_authorized? :update, @category

    @depth = @category.depth
  end

  def create
    @depth = params[:category].delete(:depth).to_i

    @category = Category.new(params[:category]) do |category|
      category.group = current_group
      category.creator = current_user
      category.depth = @depth
    end
    is_authorized? :create, @category

    if @category.save
      redirect_to([current_group, @category],
                  :notice => (current_group.category_name + ' was successfully created.'))
    else
      render :action => "new"
    end
  end

  def update
    @category = current_group.categories.find(params[:id])
    
    is_authorized? :update, @category

    @depth = @category.depth

    if @category.update_attributes(params[:category])
      redirect_to([current_group, @category],
                  :notice => (current_group.category_name + ' was successfully updated.'))
    else
      render :action => "edit"
    end
  end

  def destroy
    @category = current_group.categories.find(params[:id])
    is_authorized? :destroy, @category

    @category.destroy

    redirect_to(group_categories_url(current_group))
  end
end
