class Services::Overseers::SalesQuotes::BuildRows < Services::Shared::BaseService
  def initialize(sales_quote, inquiry_product_supplier_ids=nil)
    @sales_quote = sales_quote
    @inquiry_product_supplier_ids = inquiry_product_supplier_ids.map{ |x| x.to_i} if inquiry_product_supplier_ids.present?
  end

  def call
    sales_quote.inquiry.inquiry_products.each do |inquiry_product|
      inquiry_product.inquiry_product_suppliers.each do |inquiry_product_supplier|
        if inquiry_product_supplier_ids.present?
          if inquiry_product_supplier_ids.include?(inquiry_product_supplier.id)
            if sales_quote.rows.where(inquiry_product_supplier: inquiry_product_supplier).blank?
              sales_quote.rows.build(
                inquiry_product_supplier: inquiry_product_supplier,
                tax_code: inquiry_product_supplier.product.best_tax_code,
                measurement_unit: inquiry_product.product.measurement_unit
              )
            end
          end
        else
          if sales_quote.rows.where(inquiry_product_supplier: inquiry_product_supplier).blank?
            sales_quote.rows.build(
                inquiry_product_supplier: inquiry_product_supplier,
                tax_code: inquiry_product_supplier.product.best_tax_code,
                measurement_unit: inquiry_product.product.measurement_unit
            )
          end
        end
      end
    end

    sales_quote
  end

  attr_reader :sales_quote, :inquiry_product_supplier_ids
end
