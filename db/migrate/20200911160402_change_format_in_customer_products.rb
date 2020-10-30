class ChangeFormatInCustomerProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :customer_products, :lead_time
    add_column :customer_products, :lead_time, :integer
  end
end
