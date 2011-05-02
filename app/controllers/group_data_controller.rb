class GroupDataController < ApplicationController
  DATA_MODEL_NAME = nil
  COLLECTION_METHODS = [:index]

  load_and_authorize_resource :group
  before_filter :ensure_not_misgrouped, :except => COLLECTION_METHODS


  rescue_from RuntimeError do |exception|
    redirect_to root_url, :alert => t(:misgrouped)
  end

  private

  def ensure_not_misgrouped
    instance_variable_name = self.class::DATA_MODEL_NAME.to_s
    data_row = self.instance_variable_get("@" + instance_variable_name)
    raise "Misgrouped" if current_group && data_row && (current_group != data_row.try(:group))
  end

  def current_group
    @group
  end
end
