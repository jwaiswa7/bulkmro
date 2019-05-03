class CreateInvoiceRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :invoice_requests do |t|
      t.references :sales_order, foreign_key: true
      t.references :inquiry, foreign_key: true
      t.references :purchase_order, foreign_key: true

      t.integer :status
      t.integer :grpo_number
      t.integer :shipment_number
      t.integer :ap_invoice_number
      t.integer :ar_invoice_number

      t.string :attachments
      t.timestamps
      t.userstamps
    end
  end
end
