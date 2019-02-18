class Overseers::SalesOrders::BaseController < Overseers::BaseController
  before_action :set_sales_order_and_inquiry

  private
    def set_sales_order_and_inquiry
      @sales_order = SalesOrder.find(params[:sales_order_id])
      @inquiry = @sales_order.inquiry
    end
end
