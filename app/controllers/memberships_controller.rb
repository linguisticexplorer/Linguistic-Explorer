class MembershipsController < GroupDataController
  def index
    @memberships = current_group.memberships.paginate(:page => params[:page], :order=>"users.name").includes(:member)
  end

  def show
    @membership = current_group.memberships.find(params[:id])
  end

  def new
    @membership = Membership.new do |m|
      m.group = current_group
      m.creator = current_user
    end
    authorize! :create, @membership

    @users = User.all
  end

  def edit
    @membership = current_group.memberships.find(params[:id])
    authorize! :update, @membership

    @users = User.all
  end

  def create
    @membership = Membership.new(params[:membership]) do |membership|
      membership.group = current_group
      membership.creator = current_user
    end
    authorize! :create, @membership

    if @membership.save
      redirect_to([current_group, @membership],
                  :notice => 'Membership was successfully created.')
    else
      @users = User.all
      render :action => "new"
    end
  end

  def update
    @membership = current_group.memberships.find(params[:id])
    authorize! :update, @membership

    if @membership.update_attributes(params[:membership])
      redirect_to([current_group, @membership],
                  :notice => 'Membership was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @membership = current_group.memberships.find(params[:id])
    authorize! :destroy, @membership

    @membership.destroy

    redirect_to(group_memberships_url(current_group))
  end
end
