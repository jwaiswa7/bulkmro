class Customers::ReportsController < Customers::BaseController
  def quarterly_purchase_data
    authorize :report, :show?

    service  = Services::Customers::Charts::MixedChart.new
    @chart = service.call
  end
end