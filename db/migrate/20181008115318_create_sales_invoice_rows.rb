class CreateSalesInvoiceRows < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_invoice_rows do |t|
      t.references :sales_invoice, foreign_key: true

      t.string :sku, index: true
      t.decimal :quantity

      t.jsonb :metadata

      t.userstamps
      t.timestamps
    end
  end
end
