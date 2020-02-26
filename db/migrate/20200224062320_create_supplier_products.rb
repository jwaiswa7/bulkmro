class CreateSupplierProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :supplier_products do |t|

      t.integer :supplier_id, index: true
      t.references :product, foreign_key: true
      t.references :category, foreign_key: true
      t.references :brand, foreign_key: true

      t.string :name
      t.string :sku

      t.decimal :supplier_price, default: 0.0
      t.integer :moq
      t.decimal :unit_selling_price, default: 0.0
      t.references :tax_rate, foreign_key: true
      t.references :tax_code, foreign_key: true
      t.references :measurement_unit, foreign_key: true

      t.timestamps
      t.userstamps
    end

    add_foreign_key :supplier_products, :companies, column: :supplier_id

  end
end
