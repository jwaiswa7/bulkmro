class SupplierRfqMailer < ApplicationMailer
  default template_path: "mailers/#{self.name.underscore}"

  def request_for_quote_email(email_message, inquiry_product, quantity)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry
    @inquiry_product = inquiry_product
    @quantity = quantity
    standard_email(email_message)
  end

  def send_request_for_quote_email(email_message)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry
    email = htmlized_email(email_message)
    email.delivery_method.settings.merge!(user_name: @overseer.email, password: @overseer.smtp_password)
  end
end
