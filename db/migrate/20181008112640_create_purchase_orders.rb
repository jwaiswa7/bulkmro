class CreatePurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_orders do |t|
      t.references :inquiry, foreign_key: true
      t.jsonb :metadata

      t.integer :po_number, index: { unique: true }

      t.userstamps
      t.timestamps
    end
  end
end
