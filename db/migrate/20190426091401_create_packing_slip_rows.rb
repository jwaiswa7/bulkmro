class CreatePackingSlipRows < ActiveRecord::Migration[5.2]
  def change
    create_table :packing_slip_rows do |t|
      t.belongs_to :packing_slip
      t.string :sku
      t.timestamps
    end
  end
end
