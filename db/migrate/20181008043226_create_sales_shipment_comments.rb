class CreateSalesShipmentComments < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_shipment_comments do |t|
      t.references :sales_shipment, foreign_key: true

      t.text :message

      t.jsonb :metadata

      t.userstamps
      t.timestamps
    end
  end
end
