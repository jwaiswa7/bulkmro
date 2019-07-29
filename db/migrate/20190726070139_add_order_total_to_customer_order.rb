class AddOrderTotalToCustomerOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_orders, :calculated_total, :decimal
    add_column :customer_orders, :calculated_total_tax, :decimal
    add_column :customer_orders, :grand_total, :decimal
  end
end
