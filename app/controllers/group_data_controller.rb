class GroupDataController < ApplicationController
  before_filter :load_group_from_params

  private

  def load_group_from_params
    @group = Group.find(params[:group_id])
  end

  def current_group
    @group
  end
end
