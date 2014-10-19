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

  def contributors
    pagination_options = {db_mode: true, db_field: "name", default_field: "a", :bootstrap3 => true}

    @contributors, @params = current_group.memberships.
      includes(:member).with_role(:expert, :any).to_a.
      alpha_paginate(params[:letter], pagination_options) do |membership|
          # Handle nil (?!) values
          user = membership.member
          user.present? ? user.name : '*'
        end
    
    @resources = @contributors.map  do |contributor|
      ids = current_group.lings.find_roles(:expert, contributor).map { |role| role.resource_id }

      current_group.lings.find(ids)
    end

    Rails.logger.debug "DEBUG #{@resources.inspect}"
    # Now filter experts only
    # @contributors = memberships.keep_if { |member| member.role != 'member' }
    
    # Sort by alphabetic order
    # @contributors, @params = @contributors.
    #     alpha_paginate(params[:letter], pagination_options) do |membership|
    #       # Handle nil (?!) values
    #       user = membership.member
    #       user.present? ? user.name : '*'
    #     end

    respond_with(@contributors) do |format|
      format.html
      format.js
    end
  end
  
  def list
    render :json => current_group.memberships.includes(:member).to_json.html_safe
  end

  def show
    @membership = current_group.memberships.find(params[:id])

    is_authorized? :read, @membership

    resource_ids = @membership.roles.map(&:resource_id)

    @lings = Ling.find(resource_ids)

    if @membership.is_expert?
      # Just Lings for the moment
      @activities = Ling.where({:id => resource_ids}).order(:updated_at).first(25)
    end

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
    is_authorized? :create, @membership

    @users = User.all
  end

  def edit
    @membership = current_group.memberships.find(params[:id])
    is_authorized? :update, @membership
    
    # Stick with Ling for the moment, then will group by resource type and query them
    @lings = Ling.find(@membership.roles.map(&:resource_id))

    @users = User.all
  end

  def create
    attributes, roles = get_attributes_and_roles
      
    @membership = Membership.new(attributes) do |membership|
      membership.group = current_group
      membership.creator = current_user
    end

    is_authorized? :create, @membership

    if @membership.save
      # Set the expertise in all the passed resources
      if roles[:role] && roles[:resources].any?
        @membership.set_expertise_in roles[:resources]
      end
      redirect_to([current_group, @membership],
                  :notice => 'Membership was successfully created.')
    else
      @users = User.all
      render :action => "new"
    end
  end

  def update
    @membership = current_group.memberships.find(params[:id])

    is_authorized? :update, @membership

    attributes, roles = get_attributes_and_roles

    if @membership.update_attributes attributes
      # Set the expertise in all the passed resources
      if roles[:role] && roles[:resources].any?
        @membership.set_expertise_in roles[:resources]
      end
      redirect_to([current_group, @membership],
                  :notice => 'Membership was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @membership = current_group.memberships.find(params[:id])
    is_authorized? :destroy, @membership

    @membership.destroy

    redirect_to(group_memberships_url(current_group))
  end

  private

  def get_attributes_and_roles
    selected_role = params[:membership][:role]

    level = selected_role == 'admin' ? 'admin' : 'member';
    role  = Membership::ROLES.include? selected_role && selected_role
    
    attributes = { 
      :member_id => params[:membership][:member_id],
      :level => level
    }

    roles = {
      :role => role,
      :resources => current_group.lings.find((params[:membership][:resources] || '').split(';'))
    }

    [attributes, roles]
  end
end
