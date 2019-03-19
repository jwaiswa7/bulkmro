class AddNewFieldInSalesOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_orders, :legacy_order_number, :string
  end
end
