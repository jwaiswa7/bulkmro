class Customers::Inquiries::SalesOrdersController < Customers::Inquiries::BaseController
  before_action :get_final_sales_orders

  def index
  end

  def show
    @final_sales_order = @final_sales_orders.find(params[:id])
    respond_to do |format|
      format.html { }
      format.pdf do
        render_pdf_for @final_sales_order
      end
    end
  end

  private

    def get_final_sales_orders
      @final_sales_orders = @inquiry.final_sales_orders
    end
end
