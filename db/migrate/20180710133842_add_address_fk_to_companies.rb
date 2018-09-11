class AddAddressFkToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :companies, :addresses, column: :default_billing_address_id
    add_foreign_key :companies, :addresses, column: :default_shipping_address_id
  end
end
