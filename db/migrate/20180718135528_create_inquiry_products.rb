class CreateInquiryProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :inquiry_products do |t|
      t.references :inquiry, foreign_key: true
      t.references :product, foreign_key: true
      t.references :inquiry_import, foreign_key: true, on_delete: :nullify
      t.integer :legacy_id, index: true

      t.integer :sr_no
      t.decimal :quantity
      t.string :bp_catalog_name, index: true
      t.string :bp_catalog_sku, index: true

      t.jsonb :legacy_metadata
      t.timestamps
      t.userstamps
    end

    add_index :inquiry_products, [:inquiry_id, :product_id], unique: true
  end
end
