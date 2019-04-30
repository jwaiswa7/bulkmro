class CreateArInvoiceRows < ActiveRecord::Migration[5.2]
  def change
    create_table :ar_invoice_request_rows do |t|
      t.references :ar_invoice_request, foreign_key: true
      t.references :sales_order, foreign_key: true
      t.references :inward_dispatch_row, foreign_key: true
      t.decimal :quantity
      t.timestamps
    end
  end
end
