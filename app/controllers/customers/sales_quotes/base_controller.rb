# frozen_string_literal: true

class Customers::SalesQuotes::BaseController < Customers::BaseController
  before_action :set_sales_quote

  private

    def set_sales_quote
      @sales_quote = SalesQuote.find(params[:quote_id])
      @inquiry = @sales_quote.inquiry
    end
end
