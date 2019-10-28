class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_group

  rescue_from CanCan::AccessDenied, Exceptions::AccessDenied, :with => :show_error_message
  
  def current_group
    # Group.first # changed to default to first group
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
      unless current_user && (current_user.admin? || current_user.group_admin_of?(current_group) || current_user.is_expert_of?(resource))

        raise Exceptions::AccessDenied
      end
    end
  end

  def show_error_message(exception)
    redirect_to root_url, :alert => exception.message
  end
  
end
