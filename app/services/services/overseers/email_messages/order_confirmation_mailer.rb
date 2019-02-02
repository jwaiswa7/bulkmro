class Services::Overseers::EmailMessages::OrderConfirmationMailer < Services::Shared::BaseService

  def initialize(customer_order,current_overseer = nil)
    @customer_order = customer_order
    @current_overseer = current_overseer
  end

  def call
    if Rails.env.production?
      order_contact = Contact.find_by_email(customer_order.contact.email)
    else
      order_contact = current_overseer || Overseer.find_by_email('bhargav.trivedi@bulkmro.com')
    end
    template_id = "d-90ffe3b972c14d29ae6992a095638b80"
    template_service = Services::Overseers::EmailMessages::OrderConfirmationTemplateData.new(@customer_order, current_overseer)
    template_data = template_service.call

    template_data["name"] = customer_order.contact.to_s

    subject = "Your Bulk MRO Order Number #{customer_order.online_order_number} has been confirmed"
    contact = customer_order.contact
    service =  Services::Overseers::EmailMessages::SendEmail.new
    service.send_email_message(order_contact, template_id, template_data, subject,contact)
  end

  attr_accessor :customer_order, :current_overseer
end