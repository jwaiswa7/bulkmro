

class Overseers::CustomerOrders::BaseController < Overseers::BaseController
  before_action :set_customer_order

  private

    def set_customer_order
      @customer_order = CustomerOrder.find(params[:customer_order_id])
    end
end
