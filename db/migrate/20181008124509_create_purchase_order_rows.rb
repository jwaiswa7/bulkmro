class CreatePurchaseOrderRows < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_order_rows do |t|
      t.references :purchase_order, foreign_key: true

      t.jsonb :metadata

      t.userstamps
      t.timestamps
    end
  end
end
