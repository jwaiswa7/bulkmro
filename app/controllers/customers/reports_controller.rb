class Customers::ReportsController < Customers::BaseController

  def quarterly_purchase_data
    authorize :report, :show?
  end

end

