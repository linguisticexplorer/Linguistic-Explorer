class GroupDataController < ApplicationController
  load_and_authorize_resource :group
  before_filter :check_settings_group_data_enabled?

  private

  def check_settings_group_data_enabled?
    raise CanCan::AccessDenied unless Settings.group_data_enabled || current_user.admin?
  end

  def current_group
    @group
  end
end
