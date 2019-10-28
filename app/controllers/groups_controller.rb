class GroupsController < ApplicationController

  respond_to :html, :js

  # To add paginate method in Array class
  # https://github.com/mislav/will_paginate/wiki/Backwards-incompatibility
  require 'will_paginate/array'

  def index
    if params[:group_id]
      begin
        @group = Group.find(params[:group_id])
        is_authorized? :show, @group
        redirect_to @group
        return
      rescue ActiveRecord::RecordNotFound
      end
    end

    @groups = if user_signed_in?
      Group.accessible_by(current_ability).uniq.paginate(:page => params[:page], :order => "name")
    else
      Group.public.paginate(:page => params[:page], :order => "name")
    end
  end

  def list
    @groups = if user_signed_in?
      Group.accessible_by(current_ability).uniq
    else
      Group.public
    end
    # Check for each group when the last change on lings has been done,
    # and attach to it
    render :json => @groups.to_json(:except => [:created_at, :updated_at, :display_style]).html_safe
  end

  def show
    @group = Group.find(params[:id])
    is_authorized? :show, @group
  end

  def new
    @group = Group.new
    is_authorized? :create, @group
  end

  def edit
    @group = Group.find(params[:id])
    is_authorized? :update, @group
  end

  def create
    @group = Group.new(params[:group])
    is_authorized? :create, @group

    if @group.save
      redirect_to(@group, :notice => 'Group was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @group = Group.find(params[:id])
    is_authorized? :update, @group

    if @group.update_attributes(params[:group])
      redirect_to(@group, :notice => 'Group was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @group = Group.find(params[:id])
    is_authorized? :destroy, @group
    @group.destroy

    redirect_to(groups_url)
  end

  def user
    @groups = if user_signed_in?
      Group.accessible_by(current_ability).uniq.paginate(:page => params[:page], :order => "name")
    else
      Group.public.paginate(:page => params[:page], :order => "name")
    end
  end


  def activity
    @group = Group.find(params[:id])
    is_authorized? :manage, @group
    @list = []

        Example.where("updated_at between date_sub(now(),INTERVAL 2 WEEK) and now() AND group_id = #{params[:id]}").each do |example|
      next if example.creator_id.nil?
      user = User.find_by_id(example.creator_id)
      next if user.nil?
      item = {}
      item[:user] = user
      item[:value] = example
      item[:type] = :example
      @list << item
    end
    
    Property.where("updated_at between date_sub(now(),INTERVAL 2 WEEK) and now() AND group_id = #{params[:id]}").each do |property|
    
      next if property.creator_id.nil?
      user = User.find_by_id(property.creator_id)
    
      next if user.nil?
    
      item = {}
      item[:user] = user
      item[:value] = property
      item[:type] = :property
      @list << item
    end
     Ling.where("updated_at between date_sub(now(),INTERVAL 2 WEEK) and now() AND group_id = #{params[:id]}").each do |ling|
      next if ling.creator_id.nil?
      user = User.find_by_id(ling.creator_id)
      next if user.nil?
      item = {}
      item[:user] = user
      item[:value] = ling
      item[:type] = :ling
      @list << item
    end
    @list =  @list.sort_by {|item| item[:value].updated_at }
    @group
  end
  private

  def current_group
    #params[:group_id] && Group.find(params[:group_id]) || @group
    @group
  end
end
