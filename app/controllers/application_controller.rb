class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_group

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  
  def current_group
    Group.find(1) # changed to default to first group
  end

  def collection_authorize!(action, collection, *args)
    collection.each do |item|
      authorize! action, item, *args
    end
  end
end
