class CreateSalesShipments < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_shipments do |t|
      t.references :sales_order, foreign_key: true

      t.integer :shipment_uid
      t.jsonb :request_payload

      t.timestamps
    end
  end
end
