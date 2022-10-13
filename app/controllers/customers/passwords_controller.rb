class Customers::PasswordsController < Devise::PasswordsController
  layout 'shared/layouts/sign_in'

  def new
		super
	end
	
	def edit 
		super
	end

  protected

    def after_resetting_password_path_for(resource_or_scope)
      sign_out(resource)
      new_customers_contact_session_path
    end
end
