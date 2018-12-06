class RenameCustomerOrderAddressColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :customer_orders, :default_billing_address_id, :billing_address_id
    rename_column :customer_orders, :default_shipping_address_id, :shipping_address_id
    add_foreign_key :customer_orders, :addresses, column: :billing_address_id
    add_foreign_key :customer_orders, :addresses, column: :shipping_address_id
  end
end
