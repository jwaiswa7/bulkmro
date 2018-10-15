class Customers::Inquiries::SalesQuotesController < Customers::Inquiries::BaseController

  def index
    @sales_quotes = @inquiry.sales_quotes
  end

  def show
    @sales_quote = @inquiry.sales_quotes.find(params[:id])
    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_quote
      end
    end
  end
end