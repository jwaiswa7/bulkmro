class CustomerRfqMailer < ApplicationMailer
  default template_path: "mailers/#{self.name.underscore}"

  def rfq_submitted_email(email_message, customer_rfq)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry
    @customer_rfq = customer_rfq
    standard_email(email_message)
  end

  def send_rfq_submitted_email(email_message)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry
    attach_files(email_message.files)
    email = htmlized_email(email_message)
    email.delivery_method.settings = Settings.sendgrid_smtp.to_hash
  end

  def rfq_created(email_message)
    @contact = email_message.contact
    @inquiry = email_message.inquiry
    standard_email(email_message)
  end
end
