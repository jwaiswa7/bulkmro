class CreateSalesInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_invoices do |t|
      t.references :sales_order, foreign_key: true

      t.integer :invoice_uid
      t.jsonb :request_payload

      t.timestamps
    end
  end
end
