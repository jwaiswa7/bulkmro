class AddAddressToCustomerOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_orders, :default_billing_address_id, :integer
    add_column :customer_orders, :default_shipping_address_id, :integer
    add_column :customer_orders, :po_reference, :integer
  end
end
