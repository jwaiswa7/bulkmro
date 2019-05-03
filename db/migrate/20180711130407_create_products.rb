class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.references :brand, foreign_key: true
      t.references :category, foreign_key: true
      t.references :tax_code, foreign_key: true
      t.references :measurement_unit, foreign_key: true

      t.string :remote_uid, index: {unique: true}
      t.integer :legacy_id, index: true

      t.integer :product_type, index: true
      t.boolean :is_verified, default: false
      t.boolean :is_service, default: false

      t.decimal :weight, :decimal, default: 0.0

      t.string :name
      t.string :sku, index: {unique: true}
      t.string :trashed_sku, index: true
      t.string :mpn, index: true

      t.string :description
      t.string :meta_description
      t.string :meta_keyword
      t.string :meta_title

      t.jsonb :legacy_metadata
      t.timestamps
      t.userstamps
    end
  end
end
