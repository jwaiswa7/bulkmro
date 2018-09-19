class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.references :brand, foreign_key: true
      t.references :category, foreign_key: true
      t.references :tax_code, foreign_key: true
      t.references :measurement_unit, foreign_key: true

      t.string :name
      t.string :sku, index: { unique: true }
      t.integer :product_type, index: true

      t.boolean :is_verified, default: false

      t.string :description
      t.string :meta_description
      t.string :meta_keyword
      t.string :meta_title

      t.string :mfr_model_number

      t.timestamps
      t.userstamps
    end
  end
end
