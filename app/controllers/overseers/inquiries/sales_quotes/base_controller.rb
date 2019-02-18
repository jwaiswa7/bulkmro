# frozen_string_literal: true

class Overseers::Inquiries::SalesQuotes::BaseController < Overseers::Inquiries::BaseController
  before_action :set_sales_quote

  private

    def set_sales_quote
      @sales_quote = SalesQuote.find(params[:sales_quote_id])
    end
end
