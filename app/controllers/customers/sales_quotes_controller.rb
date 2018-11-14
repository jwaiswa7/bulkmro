class Customers::SalesQuotesController < Customers::BaseController
  before_action :set_sales_quote, only: [:show]

  def index
    authorize :sales_quote

    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Customers::Finders::SalesQuotes.new(params, current_contact)
        service.call

        @indexed_sales_quotes = service.indexed_records
        @sales_quotes = service.records.try(:reverse)
      end
    end
  end

  def show
    authorize @sales_quote

    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_quote
      end
    end
  end

  private
  def set_sales_quote
    @sales_quote = current_contact.account.sales_quotes.find(params[:id])
  end
end
