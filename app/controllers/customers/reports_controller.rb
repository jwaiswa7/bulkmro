# frozen_string_literal: true

class Customers::ReportsController < Customers::BaseController
  def monthly_purchase_data
    authorize :report, :show?

    service = Services::Customers::Charts::Builder.new
    @chart = service.monthly_purchase_data(current_company)
  end
end
