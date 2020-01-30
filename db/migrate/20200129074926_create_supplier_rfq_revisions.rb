class CreateSupplierRfqRevisions < ActiveRecord::Migration[5.2]
  def change
    create_table :supplier_rfq_revisions do |t|
      t.jsonb :rfq_data
      t.references :inquiry_product_supplier, foreign_key: true

      t.timestamps
    end
  end
end
