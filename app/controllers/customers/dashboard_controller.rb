class Customers::DashboardController < Customers::BaseController
  before_action :set_company, only: :set_warehouse
  before_action :set_warehouse, only: :show, if: (current_company.present? && current_company.id == 9523)

  def show
    @dashboard = Customers::Dashboard.new(current_contact, current_company, params)
    authorize :dashboard
  end

  def export_for_amat_customer
    authorize :dashboard
    service = Services::Customers::Exporters::AmatCustomersExporter.new()
    service.call
    redirect_to url_for(Export.amat_customer_portal.not_filtered.last.report)
  end

  def set_warehouse
    debugger
    authorize :dashboard
    @warehouses = Warehouse.all
  end

  def update_warehouse
  end

  attr_accessor :contact, :account
end
