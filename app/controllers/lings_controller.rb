class LingsController < ApplicationController
  helper :groups

#  before_filter :load_group_from_params
# TODO fixme WIP etc
#  def load_group_from_params
#    unless Group.find(params[:group_id])
#      flash[:alert] = "That group doesn't exist"
#      redirect_to home_path
#    end
#    @group = Group.find(params[:group_id])
#  end

  # GET /lings
  # GET /lings.xml
  def index
    @lings = Ling.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lings }
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

  # GET /lings/new
  # GET /lings/new.xml
  def new
    @ling = Ling.new
    @lings = Ling.find_all_by_depth(0)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => [@ling, @lings] }
    end
  end

  # GET /lings/1/edit
  def edit
    @ling = Ling.find(params[:id])
    @lings = Ling.find_all_by_depth(0)
  end

  # POST /lings
  # POST /lings.xml
  def create
    @ling = Ling.new(params[:ling])

    respond_to do |format|
      if @ling.save
        format.html { redirect_to(@ling, :notice => 'Ling was successfully created.') }
        format.xml  { render :xml => @ling, :status => :created, :location => @ling }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ling.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /lings/1
  # PUT /lings/1.xml
  def update
    @ling = Ling.find(params[:id])

    respond_to do |format|
      if @ling.update_attributes(params[:ling])
        format.html { redirect_to(@ling, :notice => 'Ling was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ling.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /lings/1
  # DELETE /lings/1.xml
  def destroy
    @ling = Ling.find(params[:id])
    @ling.destroy

    respond_to do |format|
      format.html { redirect_to(lings_url) }
      format.xml  { head :ok }
    end
  end
end
