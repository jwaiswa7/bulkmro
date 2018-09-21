class Services::Overseers::SalesQuotes::ProcessAndSave < Services::Shared::BaseService
  def initialize(sales_quote)
    @sales_quote = sales_quote
  end

  def call
    sales_quote.selected_suppliers.each do |inquiry_product_id, inquiry_product_supplier_id|
      selected_rows = sales_quote.rows.reject { |r| r.inquiry_product.id == inquiry_product_id.to_i && r.inquiry_product_supplier_id != inquiry_product_supplier_id.to_i }
      rejected_rows = sales_quote.rows.select { |r| r.inquiry_product.id == inquiry_product_id.to_i && r.inquiry_product_supplier_id != inquiry_product_supplier_id.to_i }

      sales_quote.rows.each do |row|
        row.destroy if rejected_rows.include?(row) && row.persisted?
      end

      sales_quote.rows = selected_rows
    end

    sales_quote.rows.each do |row|
      row.converted_unit_selling_price = row.calculated_converted_unit_selling_price
    end

    sales_quote.save_and_sync
  end

  attr_reader :sales_quote
end