class Customers::DashboardController < Customers::BaseController

  def show
    @dashboard = Customers::Dashboard.new(current_customers_contact, current_company, params)
    authorize :dashboard
  end

  def export_for_amat_customer
    authorize :dashboard
    service = Services::Customers::Exporters::AmatCustomersExporter.new()
    service.call
    redirect_to url_for(Export.amat_customer_portal.not_filtered.last.report)
  end

  attr_accessor :contact, :account
end
