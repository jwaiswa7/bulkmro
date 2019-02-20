class Overseers::SalesQuotes::BaseController < Overseers::BaseController
  before_action :set_sales_quote_and_inquiry

  private
    def set_sales_quote_and_inquiry
      @sales_quote = SalesQuote.find(params[:sales_quote_id])
      @inquiry = @sales_quote.inquiry
    end
end
