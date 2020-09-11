class AddReferencesToDeliveryChallanRows < ActiveRecord::Migration[5.2]
  def change
    add_reference :delivery_challan_rows, :delivery_challan, index: true
    add_column :delivery_challan_rows, :sales_order_row_id, :integer
    add_foreign_key :delivery_challan_rows, :sales_order_rows
  end
end
