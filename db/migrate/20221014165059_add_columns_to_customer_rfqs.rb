class AddColumnsToCustomerRfqs < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_rfqs, :billing_address_id, :integer
    add_column :customer_rfqs, :shipping_address_id, :integer
  end
end
