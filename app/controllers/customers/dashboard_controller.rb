class Customers::DashboardController < Customers::BaseController

  def show
    @dashboard = Customers::Dashboard.new(current_contact)
  end

  attr_accessor :contact, :account
end