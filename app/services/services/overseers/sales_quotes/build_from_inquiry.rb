class Services::Overseers::SalesQuotes::BuildFromInquiry < Services::Shared::BaseService
  def initialize(inquiry, overseer)
    @inquiry = inquiry
    @overseer = overseer
  end

  def call
    @sales_quote = inquiry.build_sales_quote(:overseer => overseer)

    sales_quote.assign_attributes(
      :billing_address_id => inquiry.billing_address_id,
      :shipping_address_id => inquiry.shipping_address_id,
    )

    inquiry.inquiry_products.each do |inquiry_product|
      inquiry_supplier = inquiry_product.inquiry_suppliers.where('unit_price > 0').order(:unit_price => :asc).first

      sales_quote.sales_products.build(
          :product => inquiry_product.product,
          :quantity => inquiry_product.quantity,
          :supplier => inquiry_supplier.supplier,
          :unit_cost_price => inquiry_supplier.unit_price,
          :margin => 15,
          :unit_sales_price => inquiry_supplier.unit_price * (1.15),
      )
    end

    sales_quote
  end

  attr_reader :inquiry, :sales_quote, :overseer
end