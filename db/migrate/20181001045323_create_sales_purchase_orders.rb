class CreateSalesPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_purchase_orders do |t|
      t.references :inquiry, foreign_key: true

      t.integer :po_uid
      t.jsonb :request_payload

      t.timestamps
    end
  end
end
