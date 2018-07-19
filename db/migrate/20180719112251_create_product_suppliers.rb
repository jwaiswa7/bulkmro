class CreateProductSuppliers < ActiveRecord::Migration[5.2]
  def change
    create_table :product_suppliers do |t|
      t.references :product, foreign_key: true
      t.integer :supplier_id, index: true

      t.timestamps
      t.userstamps
    end

    add_foreign_key :product_suppliers, :companies, column: :supplier_id
    add_index :product_suppliers, [:supplier_id, :product_id], unique: true
  end
end
