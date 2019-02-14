

class Overseers::Companies::SalesOrdersController < Overseers::Companies::BaseController
  def index
    @sales_orders = ApplyDatatableParams.to(@company.sales_orders.remote_approved, params.reject! { |k, v| k == 'company_id' })
    authorize @sales_orders
  end
end
