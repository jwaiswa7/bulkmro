class Suppliers::PurchaseOrdersController < Suppliers::BaseController
  before_action :set_sales_quote, only: [:show]

  def index
    authorize :purchase_order

    respond_to do |format|
      format.html { }
      format.json do
        service = Services::Suppliers::Finders::PurchaseOrders.new(params, current_contact, current_company)
        service.call

        @indexed_purchase_orders = service.indexed_records
        @purchase_orders = service.records.try(:reverse)
      end
    end
  end

  def show
    authorize @purchase_order
    @purchase_order_rows = @purchase_order.purchase_order_rows
    respond_to do |format|
      format.html { }
      format.pdf do
        render_pdf_for @purchase_order
      end
    end
  end

  # def export_all
  #   authorize :purchase_order
  #
  #   service = Services::Customers::Exporters::SalesQuotesExporter.new(headers, current_company)
  #   self.response_body = service.call
  #
  #   # Set the status to success
  #   response.status = 200
  # end

  private
    def set_sales_quote
      @purchase_order = PurchaseOrder.find(params[:id])
    end
end
