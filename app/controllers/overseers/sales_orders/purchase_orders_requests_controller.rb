class Overseers::SalesOrders::PurchaseOrdersRequestsController < Overseers::SalesOrders::BaseController
  def index
    po_requests = sales_order
  end
end