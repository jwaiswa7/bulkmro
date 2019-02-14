

class SalesQuoteMailer < ApplicationMailer
  default template_path: "mailers/#{self.name.underscore}"

  def acknowledgement(email_message)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry
    @sales_quote = email_message.sales_quote

    standard_email(email_message)
  end

  def send_acknowledgement(email_message)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry
    @sales_quote = email_message.sales_quote

    attach_files(email_message.files)
    email = htmlized_email(email_message)
    email.delivery_method.settings.merge!(user_name: @overseer.email, password: @overseer.smtp_password)
  end
end
