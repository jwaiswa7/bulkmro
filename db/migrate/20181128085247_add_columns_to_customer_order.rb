class AddColumnsToCustomerOrder < ActiveRecord::Migration[5.2]
  def change
    add_reference :customer_orders, :company, foreign_key: true
  end
end
