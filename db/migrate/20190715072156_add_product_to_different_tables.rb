class AddProductToDifferentTables < ActiveRecord::Migration[5.2]
  def change
    add_reference :inward_dispatch_rows, :product, foreign_key: true
    add_reference :sales_order_rows, :product, foreign_key: true
  end
end
