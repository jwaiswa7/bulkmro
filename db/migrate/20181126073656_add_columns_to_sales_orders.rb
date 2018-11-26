class AddColumnsToSalesOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_orders, :billing_address_id, :integer, index: true
    add_column :sales_orders, :shipping_address_id, :integer, index: true

    add_foreign_key :sales_orders, :addresses, column: :billing_address_id
    add_foreign_key :sales_orders, :addresses, column: :shipping_address_id
  end
end
