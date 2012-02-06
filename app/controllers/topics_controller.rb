class TopicsController < ApplicationController

  load_and_authorize_resource :forum
  load_and_authorize_resource :topic, :through => :forum, :shallow => true

  def show
    @topic.hit! if @topic
  end

  def create
    @topic.user = current_user

    if @topic.save
      flash[:notice] = "Topic was successfully created."
      redirect_to topic_url(@topic)
    else
      render :action => 'new'
    end
  end

  def update
    if @topic.update_attributes(params[:topic])
      flash[:notice] = "Topic was updated successfully."
      redirect_to topic_url(@topic)
    end
  end

  def destroy
    if @topic.destroy
      flash[:notice] = "Topic was deleted successfully."
      redirect_to forum_url(@topic.forum)
    end
  end
end
