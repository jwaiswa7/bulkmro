class Customers::SessionsController < Devise::SessionsController
  layout 'shared/layouts/sign_in'

  private
  def after_sign_in_path_for(resource_or_scope)
    customers_dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_contact_session_path
  end
end