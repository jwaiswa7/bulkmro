class Services::Overseers::SalesQuotes::BuildFromInquiry < Services::Shared::BaseService
  def initialize(inquiry, overseer)
    @inquiry = inquiry
    @overseer = overseer
  end

  def call
    @sales_quote = inquiry.sales_quotes.build(:overseer => overseer)

    inquiry.inquiry_products.with_suppliers.each do |inquiry_product|
      if inquiry_product.sales_products.blank?
        sales_quote.sales_products.build(:inquiry_supplier => inquiry_product.inquiry_suppliers.order(:unit_cost_price => :asc).first)
      end
    end

    sales_quote
  end

  attr_reader :inquiry, :sales_quote, :overseer
end