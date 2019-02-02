class Services::Overseers::EmailMessages::OrderConfirmationToAccountManagerMailer < Services::Shared::BaseService

  def initialize(customer_order,account_managers,current_overseer = nil)
    @customer_order = customer_order
    @current_overseer = current_overseer
    @account_managers = account_managers
  end

  def call
    if Rails.env.production?
      contact_managers = account_managers
    else
      contact_managers = current_overseer.present? ? [current_overseer] : Overseer.where(:email => 'bhargav.trivedi@bulkmro.com')
    end

    template_id = "d-010e1ac4cd984e5b99b2818c0dc687c1"

    template_service = Services::Overseers::EmailMessages::OrderConfirmationTemplateData.new(@customer_order, current_overseer)
    template_data = template_service.call
    template_data["user_name"] = customer_order.contact.to_s
    subject = "Please confirm the Order Number #"+ customer_order.online_order_number.to_s
    service =  Services::Overseers::EmailMessages::SendEmail.new
    service.send_email_messages(contact_managers, template_id, template_data, subject,account_managers)
  end

  attr_accessor :customer_order, :current_overseer,:account_managers
end