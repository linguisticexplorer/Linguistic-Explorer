class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_group

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  rescue_from Exceptions::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  
  def current_group
    Group.first # changed to default to first group
  end

  def collection_authorize!(action, collection, *args)
    collection.each do |item|
      is_authorized? action, item, *args
    end
  end

  def is_authorized?(action, resource, expertizeNeeded=false)
    # Use Cancan
    authorize! action, resource
    # Use Rolify if requested
    if expertizeNeeded
      unless current_user.is_expert_of? resource
        raise Exception::AccessDenied
      end
    end
  end
  
end
