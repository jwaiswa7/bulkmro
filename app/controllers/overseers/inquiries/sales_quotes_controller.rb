class Overseers::Inquiries::SalesQuotesController < Overseers::Inquiries::BaseController
  def new
    @sales_quote = Services::Overseers::SalesQuotes::BuildFromInquiry.new(@inquiry).call
    authorize @sales_quote
  end

  def update
    authorize @sales_quote
  end
end