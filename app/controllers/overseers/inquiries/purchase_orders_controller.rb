class Overseers::Inquiries::PurchaseOrdersController < Overseers::Inquiries::BaseController
  before_action :set_purchase_order, only: [:show]

  def index
    @purchase_orders = @inquiry.purchase_orders
    authorize @purchase_orders
  end

  def show
    authorize @purchase_order

    redirect_to overseers_purchase_order_path(@purchase_order, format: :pdf)
  end

  private

  def set_purchase_order
    @purchase_order = @inquiry.purchase_orders.find(params[:id])
  end
end

