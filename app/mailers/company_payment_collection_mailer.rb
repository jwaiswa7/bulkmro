class CompanyPaymentCollectionMailer < ApplicationMailer
  default template_path: "mailers/#{self.name.underscore}"
  def acknowledgement(email_message)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @company = email_message.company
    standard_email(email_message)
  end

  def send_acknowledgement(email_message)
    @overseer = email_message.overseer
    @company = email_message.company
    email = htmlized_email(email_message)
    email.delivery_method.settings.merge!(user_name: @overseer.email, password: @overseer.smtp_password)
  end
end
