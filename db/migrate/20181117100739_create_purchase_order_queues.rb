class CreatePurchaseOrderQueues < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_order_queues do |t|
      t.references :sales_order, foreign_key: true
      t.references :inquiry, foreign_key: true
      t.integer :status

      t.timestamps
      t.userstamps

    end
  end
end
