class GroupsController < ApplicationController
  def index
    if params[:group_id]
      begin
        @group = Group.find(params[:group_id])
        authorize! :show, @group
        redirect_to @group
        return
      rescue ActiveRecord::RecordNotFound
      end
    end

    @groups = if user_signed_in?
      Group.accessible_by(current_ability).uniq
    else
      Group.public
    end
  end

  def show
    @group = Group.find(params[:id])
    authorize! :show, @group
  end

  def info
    @group = Group.find(params[:id])
    authorize! :show, @group
  end

  def new
    @group = Group.new
    authorize! :create, @group
  end

  def edit
    @group = Group.find(params[:id])
    authorize! :update, @group
  end

  def create
    @group = Group.new(params[:group])
    authorize! :create, @group

    if @group.save
      redirect_to(@group, :notice => 'Group was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @group = Group.find(params[:id])
    authorize! :update, @group

    if @group.update_attributes(params[:group])
      redirect_to(@group, :notice => 'Group was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @group = Group.find(params[:id])
    authorize! :destroy, @group
    @group.destroy

    redirect_to(groups_url)
  end

  private

  def current_group
    @group
  end
end
