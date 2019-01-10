class UpdateAddressReferencesToCarts < ActiveRecord::Migration[5.2]
  def change
    rename_column :carts, :default_billing_address_id, :billing_address_id
    rename_column :carts, :default_shipping_address_id, :shipping_address_id
    add_foreign_key :carts, :addresses, column: :billing_address_id
    add_foreign_key :carts, :addresses, column: :shipping_address_id
  end
end
