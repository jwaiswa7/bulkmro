class CreateSalesOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_orders do |t|
      t.references :sales_quote, foreign_key: true
      t.integer :parent_id, index: true

      t.datetime :sent_at

      t.timestamps
      t.userstamps
    end

    add_foreign_key :sales_orders, :sales_orders, column: :parent_id
  end
end
