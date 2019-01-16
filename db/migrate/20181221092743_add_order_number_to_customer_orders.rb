class AddOrderNumberToCustomerOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_orders, :online_order_number, :integer
  end
end
