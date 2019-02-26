class AddColumnsToCustomerOrderRow < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_order_rows, :tax_code_id, :integer, foreign_key: true
    add_column :customer_order_rows, :tax_rate_id, :integer, foreign_key: true
  end
end
