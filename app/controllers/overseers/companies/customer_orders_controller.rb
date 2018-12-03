class Overseers::Companies::CustomerOrdersController < Overseers::Companies::BaseController
  def index
    @customer_orders = ApplyDatatableParams.to(CustomerOrder.all.where(:company => @company), params)
    authorize @customer_orders
  end
end