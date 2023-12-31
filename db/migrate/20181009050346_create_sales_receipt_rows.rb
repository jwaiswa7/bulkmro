class CreateSalesReceiptRows < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_receipt_rows do |t|
      t.references :sales_receipt, foreign_key: true
      t.references :sales_invoice, foreign_key: true

      t.decimal :amount, default: 0.0
      t.jsonb :metadata

      t.userstamps
      t.timestamps
    end
  end
end
