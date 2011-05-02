class HomeController < ApplicationController
  def index
    @groups = Group.accessible_by(current_ability).uniq
  end
end
