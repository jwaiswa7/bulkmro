class Overseers::CustomerOrdersController < Overseers::BaseController
  before_action :set_customer_order, only: [:show, :convert]

  def index
    @customer_orders = CustomerOrder.all
    authorize @customer_orders
  end

  def company_customer_orders
    @customer_orders = CustomerOrder.all.where(:company => Company.find(params[:company_id]))
    authorize @customer_orders
  end

  def show
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
