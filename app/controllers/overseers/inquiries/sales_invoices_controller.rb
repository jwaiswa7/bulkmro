class Overseers::Inquiries::SalesInvoicesController < Overseers::Inquiries::BaseController
  before_action :set_sales_invoice, only: [:show]

  def index
    @sales_invoices = @inquiry.invoices
    authorize @sales_invoices
  end

  def show
    authorize @sales_invoice
    @metadata = @sales_invoice.metadata.deep_symbolize_keys

    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_invoice
      end
    end
  end

  private

  def set_sales_invoice
    @sales_invoice = @inquiry.invoices.find(params[:id])
  end

end

