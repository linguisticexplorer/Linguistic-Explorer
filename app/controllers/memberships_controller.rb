class MembershipsController < GroupDataController

  # GET /memberships
  # GET /memberships.xml
  def index
    @memberships = current_group.memberships

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @memberships }
    end
  end

  # GET /memberships/1
  # GET /memberships/1.xml
  def show
    @membership = current_group.memberships.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @membership }
    end
  end

  # GET /memberships/new
  # GET /memberships/new.xml
  def new
    @membership = Membership.new do |m|
      m.group = current_group
      m.creator = current_user
    end
    authorize! :create, @membership

    @users = User.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @membership }
    end
  end

  # GET /memberships/1/edit
  def edit
    @membership = current_group.memberships.find(params[:id])
    authorize! :update, @membership

    @users = User.all
  end

  # POST /memberships
  # POST /memberships.xml
  def create
    @membership = Membership.new(params[:membership]) do |membership|
      membership.group = current_group
      membership.creator = current_user
    end
    authorize! :create, @membership

    respond_to do |format|
      if @membership.save
        format.html { redirect_to(group_membership_url(current_group, @membership), :notice => 'Membership was successfully created.') }
        format.xml  { render :xml => @membership, :status => :created, :location => @membership }
      else
        @users = User.all
        format.html { render :action => "new" }
        format.xml  { render :xml => @membership.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /memberships/1
  # PUT /memberships/1.xml
  def update
    @membership = current_group.memberships.find(params[:id])
    authorize! :update, @membership

    respond_to do |format|
      if @membership.update_attributes(params[:membership])
        format.html { redirect_to(group_membership_url(current_group, @membership), :notice => 'Membership was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @membership.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /memberships/1
  # DELETE /memberships/1.xml
  def destroy
    @membership = current_group.memberships.find(params[:id])
    authorize! :destroy, @membership

    @membership.destroy

    respond_to do |format|
      format.html { redirect_to(group_memberships_url(current_group)) }
      format.xml  { head :ok }
    end
  end
end
