class CreatePackingSlips < ActiveRecord::Migration[5.2]
  def change
    create_table :packing_slips do |t|
      t.integer :box_number
      t.belongs_to :outward_dispatch
      t.string :box_detail
      t.timestamps
      t.userstamps
    end
  end
end
