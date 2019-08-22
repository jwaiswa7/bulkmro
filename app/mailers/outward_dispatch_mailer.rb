class OutwardDispatchMailer < ApplicationMailer
  default template_path: "mailers/#{self.name.underscore}"

  def dispatch_mail_to_customer(email_message)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry
    @sales_order = email_message.sales_order
    @outward_dispatch = email_message.outward_dispatch

    attach_files(email_message.files)
    standard_email(email_message)
  end

  def send_customer_notification(email_message)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry
    @sales_order = email_message.sales_order
    @outward_dispatch = email_message.outward_dispatch
    attach_files(email_message.files)
    email = htmlized_email(email_message)
    email.delivery_method.settings.merge!(user_name: @overseer.email, password: @overseer.smtp_password)
  end
end