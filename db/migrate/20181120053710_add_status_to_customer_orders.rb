class AddStatusToCustomerOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_orders, :status, :string
  end
end
