class Api::V1::Users::SessionsController < Overseers::BaseController

  def sign_in
    debugger
  end

  private
    def after_sign_in_path_for(resource_or_scope)
      customers_dashboard_path
    end

    def after_sign_out_path_for(resource_or_scope)
      new_customers_contact_session_path
    end
end