class GroupDataController < ApplicationController
  before_filter :load_and_authorize_group_from_params

  private

  def load_and_authorize_group_from_params
    @group = Group.find(params[:group_id])
    authorize! :read, @group
  end

  def current_group
    @group
  end
end
