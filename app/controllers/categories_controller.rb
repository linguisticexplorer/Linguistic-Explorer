class CategoriesController < GroupDataController

  # GET /categories
  # GET /categories.xml
  def index
    @categories = current_group.categories

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @categories }
    end
  end

  # GET /categories/1
  # GET /categories/1.xml
  def show
    @category = current_group.categories.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @category }
    end
  end

  # GET /categories/new
  # GET /categories/new.xml
  def new
    @depth = params[:depth].to_i
    @category = Category.new do |c|
      c.group = current_group
      c.creator = current_user
      c.depth = @depth
    end
    authorize! :create, @category

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category }
    end
  end

  # GET /categories/1/edit
  def edit
    @category = Category.find(params[:id])
  end

  # POST /categories
  # POST /categories.xml
  def create
    @depth = params[:category].delete(:depth).to_i
    @category = Category.new(params[:category]) do |category|
      category.group = current_group
      category.creator = current_user
      category.depth = @depth
    end

    respond_to do |format|
      if @category.save
        format.html { redirect_to(group_category_url(current_group, @category), :notice => (current_group.category_name + ' was successfully created.')) }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.xml
  def update
    @category = Category.find(params[:id])

    respond_to do |format|
      if @category.update_attributes(params[:category])
        format.html { redirect_to(group_category_url(current_group, @category), :notice => (current_group.category_name + ' was successfully updated.')) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    @category = Category.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.html { redirect_to(group_categories_url(current_group)) }
      format.xml  { head :ok }
    end
  end
end
