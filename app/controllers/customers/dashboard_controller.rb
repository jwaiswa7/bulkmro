class Customers::DashboardController < Customers::BaseController

  def show
    @dashboard = Customers::Dashboard.new(current_customers_contact, current_company, params)
    authorize :dashboard
  end

  def route
    contact = Contact.find_by_email(contact_params['email'])
    sign_in(:customers_contact, contact)
    session[:api_request] = true
    session[:api_request_id] = contact_params['request_id']
    redirect_to customers_dashboard_url(became: true)
  end

  def export_for_amat_customer
    authorize :dashboard
    service = Services::Customers::Exporters::AmatCustomersExporter.new()
    service.call
    redirect_to url_for(Export.amat_customer_portal.not_filtered.last.report)
  end

  private

  def contact_params
    params.permit(:email, :request_id)
  end

  attr_accessor :contact, :account
end
