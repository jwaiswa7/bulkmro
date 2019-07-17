class Customers::SalesOrdersController < Customers::BaseController
  before_action :set_sales_order, only: [:show]

  def index
    authorize :sales_order

    respond_to do |format|
      format.html { }
      format.json do
        service = Services::Customers::Finders::SalesOrders.new(params, current_contact, current_company)
        service.call

        @indexed_sales_orders = service.indexed_records
        @sales_orders = service.records.try(:reverse)
      end
    end
  end

  def show
    authorize @sales_order

    respond_to do |format|
      format.html { }
      format.pdf do
        render_pdf_for @sales_order
      end
    end
  end

  def export_all
    authorize :sales_order

    if params.present?
      service = Services::Customers::Exporters::SalesOrdersExporter.new(headers, current_company, params)
    else
      puts '****************************** ABESENT PARAMS *******************************'
      binding.pry
    end
    self.response_body = service.call

    # Set the status to success
    response.status = 200
  end

  private
    def set_sales_order
      @sales_order = current_company.sales_orders.find(params[:id])
    end
end
