class Services::Overseers::SalesQuotes::BuildFromInquiry < Services::Shared::BaseService
  def initialize(inquiry)
    @inquiry = inquiry
  end

  def call
    @sales_quote = inquiry.build_sales_quote

    sales_quote
  end

  attr_reader :inquiry, :sales_quote
end