class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_group

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def current_group
    nil # A stub so that the nav bar always gets a nil if current_group isn't defined/available
  end

  def collection_authorize!(action, collection, *args)
    collection.each do |item|
      authorize! action, item, *args
    end
  end
end
