class GroupDataController < ApplicationController
  load_and_authorize_resource :group

private
  def current_group
    @group
  end
end
