class Customers::SalesOrdersController < Customers::BaseController

  def index
    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Customers::Finders::SalesOrders.new(params, current_contact)
        service.call

        @indexed_sales_orders = service.indexed_records
        @sales_orders = service.records.try(:reverse)
      end
    end
  end

  def show
    @sales_order = SalesOrder.find(params[:id])
    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_order
      end
    end
  end

end
