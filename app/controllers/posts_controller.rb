class PostsController < ApplicationController

  load_and_authorize_resource :topic
  load_and_authorize_resource :post, :through => :topic, :shallow => true

  def new
    if params[:quote]
      quote_post = Post.find(params[:quote])
      if quote_post
        @post.body = "[quote]#{quote_post.body}[/quote]"
      end
    end
  end

  def create
    @post.user = current_user

    if @post.save
      flash[:notice] = "Post was successfully created."
      redirect_to topic_path(@post.topic)
    else
      render :action => 'new'
    end
  end

  def update
    if @post.update_attributes(params[:post])
      flash[:notice] = "Post was successfully updated."
      redirect_to topic_path(@post.topic)
    end
  end

  def destroy
    if @post.topic.posts_count > 1
      if @post.destroy
        flash[:notice] = "Post was successfully destroyed."
        redirect_to topic_path(@post.topic)
      end
    else
      if @post.topic.destroy
        flash[:notice] = "Topic was successfully deleted."
        redirect_to forum_path(@post.forum)
      end
    end
  end
end