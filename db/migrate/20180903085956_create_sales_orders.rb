class CreateSalesOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_orders do |t|
      t.references :sales_quote, foreign_key: true
      t.integer :parent_id, index: true
      t.integer :legacy_id, index: true
      t.integer :remote_uid, index: true

      t.integer :legacy_request_status, index: true
      t.integer :remote_status, index: true
      t.integer :status, index: true

      t.integer :order_number
      t.integer :draft_uid

      t.datetime :sent_at

      t.jsonb :legacy_metadata
      t.timestamps
      t.userstamps
    end

    add_foreign_key :sales_orders, :sales_orders, column: :parent_id
  end
end
