class CreateSalesReceiptRows < ActiveRecord::Migration[5.2]
  def change
    drop_table :sales_receipt_rows
    create_table :sales_receipt_rows do |t|
      t.references :sales_receipt, foreign_key: true
      t.references :sales_invoice, foreign_key: true
      t.decimal :amount_received

      t.userstamps
      t.timestamps
    end
  end
end
