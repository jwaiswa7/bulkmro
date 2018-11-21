class CreatePurchaseOrderComments < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_order_comments do |t|
      t.references :purchase_order_queue, foreign_key: true
      t.text :message

      t.userstamps
      t.timestamps
    end
  end
end
