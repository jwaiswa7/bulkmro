class Overseers::CustomerOrdersController < Overseers::BaseController
  before_action :set_customer_order, only: [:view, :convert]

  def index
    @customer_orders = CustomerOrder.all
    authorize @customer_orders
  end

  def view
    authorize @customer_order
  end

  def convert
    authorize @customer_order
  end

  private

  def set_customer_order
    @customer_order = CustomerOrder.find(params[:id])
  end
end
