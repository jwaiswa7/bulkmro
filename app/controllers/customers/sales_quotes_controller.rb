class Customers::SalesQuotesController < Customers::BaseController

  def index
    account = current_contact.account
    @sales_quotes = ApplyDatatableParams.to(account.sales_quotes, params)
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

