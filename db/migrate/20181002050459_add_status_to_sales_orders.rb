class AddStatusToSalesOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_orders, :status, :integer, index: true
  end
end