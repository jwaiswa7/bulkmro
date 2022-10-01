class AddIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :sales_orders, :id
    add_index :sales_orders, :created_at
    add_index :sales_quote_rows, :id
    add_index :accounts, :id 
    add_index :products, :id 
  end
end
