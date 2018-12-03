class Overseers::Companies::SalesOrdersController < Overseers::Companies::BaseController
  def index
    @sales_orders = ApplyDatatableParams.to(@company.sales_orders.remote_approved, params)
    authorize @sales_orders
  end
end
