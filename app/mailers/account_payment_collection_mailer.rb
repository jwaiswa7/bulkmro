class AccountPaymentCollectionMailer < ApplicationMailer
  default :template_path => "mailers/#{self.name.underscore}"
  def acknowledgement(email_message)
    @overseer = email_message.overseer
    @account = email_message.account
    standard_email(email_message)
  end

  def send_acknowledgement(email_message)
    @overseer = email_message.overseer
    email = htmlized_email(email_message)
    email.delivery_method.settings.merge!({user_name: @overseer.email, password: @overseer.smtp_password})
  end
end