class AddAddressToCarts < ActiveRecord::Migration[5.2]
  def change
    add_column :carts, :default_billing_address_id, :integer
    add_column :carts, :default_shipping_address_id, :integer
    add_column :carts, :po_reference, :integer
  end
end
