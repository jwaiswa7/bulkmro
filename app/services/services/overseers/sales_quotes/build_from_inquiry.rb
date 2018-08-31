class Services::Overseers::SalesQuotes::BuildFromInquiry < Services::Shared::BaseService
  def initialize(inquiry, overseer)
    @inquiry = inquiry
    @overseer = overseer
  end

  def call
    @sales_quote = inquiry.sales_quotes.build(:overseer => overseer)

    inquiry.inquiry_suppliers.each do |inquiry_product|
      inquiry_supplier = inquiry_product.inquiry_suppliers.where('unit_price > 0').order(:unit_price => :asc).first

      # sales_quote.sales_products.build(
      #     :product => inquiry_product.product,
      #     :quantity => inquiry_product.quantity,
      #     :supplier => inquiry_supplier.supplier,
      #     :unit_cost_price => inquiry_supplier.unit_price,
      #     :margin => 15,
      #     :unit_sales_price => inquiry_supplier.unit_price * (1.15),
      # )
    end

    sales_quote
  end

  attr_reader :inquiry, :sales_quote, :overseer
end