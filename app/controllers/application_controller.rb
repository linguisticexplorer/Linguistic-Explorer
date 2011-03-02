class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_group

  def current_group
    nil # A stub so that the nav bar always gets a nil if current_group isn't defined/available
  end
end
