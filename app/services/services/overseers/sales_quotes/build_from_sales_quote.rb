class Services::Overseers::SalesQuotes::BuildFromSalesQuote < Services::Shared::BaseService
  def initialize(old_sales_quote, overseer)
    @old_sales_quote = old_sales_quote
    @overseer = overseer
  end

  def call
    @sales_quote = old_sales_quote.deep_clone include: :sales_products

    sales_quote.assign_attributes(:overseer => overseer)
    sales_quote.assign_attributes(:parent_id => old_sales_quote.id)
    sales_quote.assign_attributes(:sent_at => nil)
    sales_quote.sales_products.each do |sales_product|
      sales_product.assign_attributes(:overseer => overseer)
    end

    sales_quote
  end

  attr_reader :old_sales_quote, :overseer, :sales_quote
end