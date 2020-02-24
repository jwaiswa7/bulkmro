class Customers::SalesInvoicesController < Customers::BaseController
  before_action :set_sales_invoice, only: [:show, :show_pods]

  def index
    authorize :sales_invoice

    respond_to do |format|
      format.html { }
      format.json do
        service = Services::Customers::Finders::SalesInvoices.new(params, current_contact, current_company)
        service.call

        @indexed_sales_invoices = service.indexed_records
        @sales_invoices = service.records.try(:reverse)
      end
    end
  end

  def show
    authorize @sales_invoice

    @bill_from_warehouse = @sales_invoice.get_bill_from_warehouse
    respond_to do |format|
      format.html { }
      format.pdf do
        render_pdf_for @sales_invoice, locals
      end
    end
  end

  def export_all
    authorize :sales_invoice

    service = Services::Customers::Exporters::SalesInvoicesExporter.new(headers, current_company)
    self.response_body = service.call

    # Set the status to success
    response.status = 200
  end

  def show_pods
    authorize @sales_invoice
  end

  private
    def set_sales_invoice
      @sales_invoice = current_contact.account.invoices.find(params[:id])
      @locals = { stamp: false }
      if params[:stamp].present?
        @locals = { stamp: true }
      end
    end

    attr_accessor :locals
end
