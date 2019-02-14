class Services::Overseers::SalesQuotes::BuildRows < Services::Shared::BaseService
  def initialize(sales_quote)
    @sales_quote = sales_quote
  end

  def call
    sales_quote.inquiry.inquiry_products.each do |inquiry_product|
      inquiry_product.inquiry_product_suppliers.each do |inquiry_product_supplier|
        if sales_quote.rows.where(inquiry_product_supplier: inquiry_product_supplier).blank?
          sales_quote.rows.build(
            inquiry_product_supplier: inquiry_product_supplier,
            tax_code: inquiry_product_supplier.product.best_tax_code,
            measurement_unit: inquiry_product.product.measurement_unit
          )
        end
      end
    end

    sales_quote
  end

  attr_reader :sales_quote
end
