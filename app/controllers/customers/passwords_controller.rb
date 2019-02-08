class Customers::PasswordsController < Devise::PasswordsController
  layout 'shared/layouts/sign_in'

  protected
  def after_resetting_password_path_for(resource_or_scope)
    new_contact_session_path
  end
end