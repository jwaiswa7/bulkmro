class Customers::SalesQuotesController < Customers::BaseController

  def index
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
    @sales_quote = SalesQuote.find(params[:id])
    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_quote
      end
    end
  end

end

