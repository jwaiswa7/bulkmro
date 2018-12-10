class Customers::SessionsController < Devise::SessionsController
  layout 'shared/layouts/sign_in'

  #TODO Reset selected company on sign out
=begin
  before_action reset_company, only: [:new]

  private
  def reset_company
    @@current_company = nil
  end
=end

  private
  def after_sign_in_path_for(resource_or_scope)
    choose_company_customers_companies_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_contact_session_path
  end
end