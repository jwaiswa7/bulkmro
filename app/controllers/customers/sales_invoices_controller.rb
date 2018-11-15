class Customers::SalesInvoicesController < Customers::BaseController
  before_action :set_sales_invoice, only: [:show]

  def index
    authorize :sales_invoice

    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Customers::Finders::SalesInvoices.new(params, current_contact)
        service.call

        @indexed_sales_invoices = service.indexed_records
        @sales_invoices = service.records.try(:reverse)
      end
    end
  end

  def show
    authorize @sales_invoice

    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_invoice
      end
    end
  end

  private
  def set_sales_invoice
    @sales_invoice = current_contact.account.invoices.find(params[:id])
  end
end
