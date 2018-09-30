class AddColumnRemoteStatusToSalesOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_orders, :remote_status, :integer
  end
end
