class Suppliers::DashboardController < Suppliers::BaseController
  def show
    @dashboard = Suppliers::Dashboard.new(current_suppliers_contact, current_company, params)
    authorize :dashboard
  end

  attr_accessor :contact, :account
end
