class RenameBoxDetailToDimensionPackingSlips < ActiveRecord::Migration[5.2]
  def change
    rename_column :packing_slips, :box_detail, :box_dimension unless column_exists? :packing_slips, :box_dimension
  end
end
