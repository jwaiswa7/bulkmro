class AddApprovedDateToSalesOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_orders, :approved_date, :timestamp
  end
end
