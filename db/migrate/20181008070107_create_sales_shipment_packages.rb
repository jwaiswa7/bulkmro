class CreateSalesShipmentPackages < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_shipment_packages do |t|
      t.references :sales_shipment, foreign_key: true
      t.references :sales_invoice, foreign_key: true

      t.string :tracking_number, index: { unique: true }

      t.jsonb :metadata

      t.userstamps
      t.timestamps
    end
  end
end
