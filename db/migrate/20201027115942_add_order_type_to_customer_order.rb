class AddOrderTypeToCustomerOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_orders, :order_type, :integer, default: 10
  end
end
