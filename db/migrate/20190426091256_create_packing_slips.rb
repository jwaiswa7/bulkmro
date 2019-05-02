class CreatePackingSlips < ActiveRecord::Migration[5.2]
  def change
    create_table :packing_slips do |t|
      t.integer :box_number
      t.belongs_to :outward_dispatch
      t.string :sku
      t.decimal :quantity_stocked
      t.decimal :delivery_quantity
      t.timestamps
    end
  end
end
