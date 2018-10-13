class CreateSalesQuoteRows < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_quote_rows do |t|
      t.references :sales_quote, foreign_key: true
      t.references :inquiry_product_supplier, foreign_key: true
      t.references :tax_code, foreign_key: true
      t.references :lead_time_option, foreign_key: true

      t.decimal :quantity
      t.decimal :margin_percentage

      t.decimal :unit_selling_price
      t.decimal :converted_unit_selling_price
      t.decimal :freight_cost_subtotal
      t.decimal :unit_freight_cost

      t.string :legacy_applicable_tax
      t.string :legacy_applicable_tax_class
      t.decimal :legacy_applicable_tax_percentage

      t.timestamps
      t.userstamps
    end

    add_index :sales_quote_rows, [:sales_quote_id, :inquiry_product_supplier_id], unique: true, name: 'index_sqr_on_sales_quote_id_and_inquiry_product_supplier_id'
  end
end
