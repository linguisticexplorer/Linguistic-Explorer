class Users::RegistrationsController < Devise::RegistrationsController
  def create
    build_resource
    resource.email = params[:user][:email]
    resource.access_level = "user"

    if resource.save
      set_flash_message :notice, :signed_up
      sign_in_and_redirect(resource_name, resource)
    else
      clean_up_passwords(resource)
      render_with_scope :new
    end
  end
end
