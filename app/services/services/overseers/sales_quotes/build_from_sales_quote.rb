# frozen_string_literal: true

class Services::Overseers::SalesQuotes::BuildFromSalesQuote < Services::Shared::BaseService
  def initialize(old_sales_quote, overseer)
    @old_sales_quote = old_sales_quote
    @overseer = overseer
  end

  def call
    @sales_quote = old_sales_quote.deep_clone include: :rows

    sales_quote.assign_attributes(overseer: overseer)
    sales_quote.assign_attributes(parent_id: old_sales_quote.id)
    sales_quote.assign_attributes(sent_at: nil)
    sales_quote.rows.each do |row|
      row.assign_attributes(overseer: overseer)
      row.assign_attributes(sales_quote_id: old_sales_quote.id)
    end

    sales_quote.inquiry.inquiry_products.each do |inquiry_product|
      inquiry_product.inquiry_product_suppliers.each do |inquiry_product_supplier|
        sales_quote.rows.build(
          inquiry_product_supplier: inquiry_product_supplier,
          tax_code: inquiry_product_supplier.product.best_tax_code,
          measurement_unit: inquiry_product.product.measurement_unit
        ) if sales_quote.rows.select { |r| r.inquiry_product_supplier == inquiry_product_supplier }.blank?
      end
    end

    sales_quote
  end

  attr_reader :old_sales_quote, :overseer, :sales_quote
end
