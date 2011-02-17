class HomeController < ApplicationController
  def index
    @groups = Group.all
    @group = Group.first
  end
end
