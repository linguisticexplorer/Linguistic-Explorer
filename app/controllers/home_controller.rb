class HomeController < ApplicationController
  def index
    @groups = if user_signed_in?
      Group.accessible_by(current_ability).uniq
    else
      Group.public
    end
  end
end
