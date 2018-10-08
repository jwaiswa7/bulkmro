class Callbacks::PurchaseOrdersController < Callbacks::BaseController

  def create
    service = Services::Overseers::Callbacks::PurchaseOrders::Create.new(params)
    service.call

    render_successful
  end

end