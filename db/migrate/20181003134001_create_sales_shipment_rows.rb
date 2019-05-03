class CreateSalesShipmentRows < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_shipment_rows do |t|
      t.references :sales_shipment, foreign_key: true
      t.integer :sku
      t.decimal :quantity

      t.jsonb :metadata

      t.timestamps
    end
  end
end
