class Overseers::PurchaseOrdersController < Overseers::BaseController

  def index
    @purchase_orders = PurchaseOrder.all
    authorize @purchase_orders
  end

end