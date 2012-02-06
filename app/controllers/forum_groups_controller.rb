class ForumGroupsController < ApplicationController

  load_and_authorize_resource :forum_group
  
  def create
    if @forum_group.save
      flash[:notice] = "Forum Group was successfully created."
      redirect_to forums_url
    else
      render :action => 'new'
    end
  end
  
  def update
    if @forum_group.update_attributes(params[:forum_group])
      flash[:notice] = "Forum Group was updated successfully."
      redirect_to forums_url
    end
  end
  
  def destroy
    if @forum_group.destroy
      flash[:notice] = "Forum Group was deleted."
      redirect_to forums_url
    end
  end
end