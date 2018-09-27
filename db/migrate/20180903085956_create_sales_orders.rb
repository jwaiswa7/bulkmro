class CreateSalesOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_orders do |t|
      t.references :sales_quote, foreign_key: true
      t.integer :parent_id, index: true
      t.integer :legacy_id, index: true
      t.string :remote_uid, index: true
      t.integer :legacy_request_status

      t.string :order_number
      t.string :sap_series
      t.string :doc_number

      t.datetime :sent_at

      t.timestamps
      t.userstamps
    end

    add_foreign_key :sales_orders, :sales_orders, column: :parent_id
  end
end
