class Overseers::CustomerOrdersController < Overseers::BaseController
  before_action :set_customer_order, only: [:show]

  def index
    @customer_orders = ApplyDatatableParams.to(CustomerOrder.all.order(id: :desc), params)
    authorize @customer_orders
  end

  def payments
    @payments = OnlinePayment.all
    authorize :customer_order
  end

  def show
    authorize @customer_order
  end

  private
  def set_customer_order
    @customer_order = CustomerOrder.find(params[:id])
  end
end
