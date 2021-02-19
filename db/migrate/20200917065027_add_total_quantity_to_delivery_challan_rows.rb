class AddTotalQuantityToDeliveryChallanRows < ActiveRecord::Migration[5.2]
  def change
  	add_column :delivery_challan_rows, :total_quantity, :integer
  	add_reference :delivery_challan_rows, :inward_dispatch_row, index: true
  end
end
