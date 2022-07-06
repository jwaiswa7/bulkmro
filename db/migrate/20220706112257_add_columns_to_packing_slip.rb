class AddColumnsToPackingSlip < ActiveRecord::Migration[5.2]
  def change
    add_column :packing_slips, :bill_to, :string
    add_column :packing_slips, :billing_address, :string
    add_reference :packing_slips, :ship_to, index: true 
    add_reference :packing_slips, :shipping_address, index: true
  end
end
