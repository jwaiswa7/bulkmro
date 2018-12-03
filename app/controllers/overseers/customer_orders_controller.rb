class Overseers::CustomerOrdersController < Overseers::BaseController
  before_action :set_customer_order, only: [:show, :convert]

  def index
    @customer_orders = ApplyDatatableParams.to(CustomerOrder.all, params)
    authorize @customer_orders
  end

  def show
    authorize @customer_order
  end

  private
  def set_customer_order
    @customer_order = CustomerOrder.find(params[:id])
  end
end
