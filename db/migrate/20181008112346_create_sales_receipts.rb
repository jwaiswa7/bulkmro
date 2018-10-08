class CreateSalesReceipts < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_receipts do |t|
      t.references :sales_invoice, foreign_key: true
      t.jsonb :metadata

      t.userstamps
      t.timestamps
    end
  end
end
