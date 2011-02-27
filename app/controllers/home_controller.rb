class HomeController < ApplicationController
  def index
    @groups = Group.all
  end
end
