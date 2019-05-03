class CreateSalesShipments < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_shipments do |t|
      t.references :sales_order, foreign_key: true
      t.integer :remote_uid, index: { unique: true }
      t.jsonb :metadata

      t.integer :status

      t.timestamps
      t.userstamps
    end
  end
end
