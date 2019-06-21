class SalesInvoiceMailer < ApplicationMailer
  default template_path: "mailers/#{self.name.underscore}"

  def delivery_mail(email_message)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry

    standard_email(email_message)
  end

  def send_delivery_mail(email_message)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry

    attach_files(email_message.files)
    email = htmlized_email(email_message)
    email.delivery_method.settings.merge!(user_name: @overseer.email, password: @overseer.smtp_password)
  end
end
