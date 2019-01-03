class Customers::SessionsController < Devise::SessionsController
  layout 'shared/layouts/sign_in'

  def edit_current_company
    current_contact
  end

  def set_current_company
    current_contact
  end

  private
  def after_sign_in_path_for(resource_or_scope)
    choose_company_customers_companies_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_contact_session_path
  end
end