class CreateDeliveryChallanRows < ActiveRecord::Migration[5.2]
  def change
    create_table :delivery_challan_rows do |t|
      t.references :inquiry_product, foreign_key: true
      t.references :product, foreign_key: true

      t.integer :sr_no
      t.integer :quantity

      t.timestamps
      t.userstamps
    end
  end
end
