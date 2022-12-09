class Customers::SalesQuotesController < Customers::BaseController
  before_action :set_sales_quote, only: [:show]

  def index
    authorize :sales_quote

    respond_to do |format|
      format.html { }
      format.json do
        selected_company = current_customers_contact.customer_admin? ? nil: current_company
        service = Services::Customers::Finders::SalesQuotes.new(params, current_customers_contact, selected_company)
        service.call

        @indexed_sales_quotes = service.indexed_records
        @sales_quotes = service.records.try(:reverse)
      end
    end
  end

  def show
    authorize @sales_quote
    @sales_quote_rows = @sales_quote.sales_quote_rows
    is_revision_visible = params[:is_revision_visible]
    respond_to do |format|
      format.html { }
      format.pdf do
        render_pdf_for(@sales_quote, locals: {is_revision_visible:  is_revision_visible})
      end
    end
  end

  def export_all
    authorize :sales_order

    service = Services::Customers::Exporters::SalesQuotesExporter.new(headers, current_company)
    self.response_body = service.call

    # Set the status to success
    response.status = 200
  end

  private
    def set_sales_quote
      @sales_quote = SalesQuote.find(params[:id])
    end
end
