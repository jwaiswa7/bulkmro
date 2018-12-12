class Customers::ReportsController < Customers::BaseController
  def quarterly_purchase_data
    authorize :report, :show?

    service  = Services::Customers::Charts::DataGenerator.new
    @chart = service.get_multi_axis_mixed_chart
  end
end