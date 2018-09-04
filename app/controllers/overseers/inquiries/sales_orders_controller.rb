class Overseers::Inquiries::SalesOrdersController < Overseers::Inquiries::BaseController
  def index
    @sales_orders = @inquiry.sales_orders
    authorize @sales_orders
  end

  private
end