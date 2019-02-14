

class Overseers::Companies::CustomerOrdersController < Overseers::Companies::BaseController
  def index
    @customer_orders = ApplyDatatableParams.to(@company.customer_orders, params.reject! { |k, v| k == 'company_id' })
    # puts @customer_orders.size
    authorize @customer_orders

    render 'overseers/customer_orders/index'
  end
end
