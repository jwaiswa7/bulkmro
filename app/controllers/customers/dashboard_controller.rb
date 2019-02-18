# frozen_string_literal: true

class Customers::DashboardController < Customers::BaseController
  def show
    @dashboard = Customers::Dashboard.new(current_contact)
    authorize :dashboard
  end

  attr_accessor :contact, :account
end
