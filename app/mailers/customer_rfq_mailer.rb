class CustomerRfqMailer < ApplicationMailer
  default template_path: "mailers/#{self.name.underscore}"

  def rfq_submitted_email(email_message, customer_rfq)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry
    @customer_rfq = customer_rfq
    standard_email(email_message)
  end
end
