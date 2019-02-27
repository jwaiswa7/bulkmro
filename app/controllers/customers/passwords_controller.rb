class Customers::PasswordsController < Devise::PasswordsController
  layout 'shared/layouts/sign_in'

  def create
    template_data = {}

    template_id = 'd-4444921d3e6b4ea89c396aecaa270261'
    contact = resource_params
    token = resource_class.set_reset_password_token
    template_data['name'] = contact
    template_data['action_url'] = edit_password_url(resource, reset_password_token: token) #todo

    service = Services::Customers::EmailMessages::SendEmail.new
    service.send_email_messages(contact, template_id, template_data, nil)

    # self.resource = resource_class.send_reset_password_instructions(resource_params)
    # yield resource if block_given?

    if successfully_sent?(resource)
      respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end

  # def update
  #   self.resource = resource_class.reset_password_by_token(resource_params)
  #   yield resource if block_given?
  #
  #   if resource.errors.empty?
  #     resource.unlock_access! if unlockable?(resource)
  #     if Devise.sign_in_after_reset_password
  #       flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
  #       set_flash_message!(:notice, flash_message)
  #       resource.after_database_authentication
  #       sign_in(resource_name, resource)
  #     else
  #       set_flash_message!(:notice, :updated_not_active)
  #     end
  #     respond_with resource, location: after_resetting_password_path_for(resource)
  #   else
  #     set_minimum_password_length
  #     respond_with resource
  #   end
  # end

  protected

  def after_resetting_password_path_for(resource_or_scope)
    sign_out(resource)
    new_contact_session_path
  end
end
