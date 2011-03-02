class GroupDataController < ApplicationController
  before_filter :load_group_from_params

  def load_group_from_params
    session[:group] = Group.find(params[:group_id])
  end

  def current_group
    session[:group]
  end
end
