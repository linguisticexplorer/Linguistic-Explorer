class MembershipsController < GroupDataController

  respond_to :html, :js

  def index
    pagination_options = {db_mode: true, db_field: "name", default_field: "a", :bootstrap3 => true}
    @memberships, @params = current_group.memberships.
        includes(:member).to_a.
        alpha_paginate(params[:letter], pagination_options) do |membership|
          # Handle nil (?!) values
          user = membership.member
          user.present? ? user.name : '*'
        end

    respond_with(@memberships) do |format|
      format.html
      format.js
    end
  end
  
  def list
    @all_members = Hash.new
    current_group.memberships.includes(:member).find_each(:batch_size => 500) do |memb|
      @all_members[memb.member.name] = memb.id
    end
    render :json => @all_members.to_json.html_safe
  end

  def show
    @membership = current_group.memberships.find(params[:id])

    respond_with(@membership) do |format|
      format.html
      format.js
    end
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
    @membership.grant_role params[:membership][:role][:type], params[:membership][:role][:instance]

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
