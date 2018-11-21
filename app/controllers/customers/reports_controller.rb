class Customers::ReportsController < Customers::BaseController

  def show
    authorize :show
  end

end

