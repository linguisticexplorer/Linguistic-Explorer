class Users::RegistrationsController < Devise::RegistrationsController
  def create
    email = params[:user].delete(:email)
    build_resource sign_up_params
    resource.email = email
    resource.access_level = User::USER

    result = resource.save

    if result
      set_flash_message :notice, :signed_up
      sign_in_and_redirect(resource_name, resource)
    else
      clean_up_passwords(resource)
      render :new
    end
  end
end
