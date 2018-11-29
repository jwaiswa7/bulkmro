class Overseers::Companies::PurchaseOrdersController < Overseers::Companies::BaseController

  def index
    authorize :purchase_order
  end
end