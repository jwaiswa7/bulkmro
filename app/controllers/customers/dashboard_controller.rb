class Customers::DashboardController < Customers::BaseController

  def show
    @dashboard = Customers::Dashboard.new(current_contact, current_company, params)
    authorize :dashboard
  end

  attr_accessor :contact, :account
end