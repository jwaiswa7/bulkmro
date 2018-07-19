class CreateBrandSuppliers < ActiveRecord::Migration[5.2]
  def change
    create_table :brand_suppliers do |t|
      t.references :brand, foreign_key: true
      t.integer :supplier_id, index: true

      t.timestamps
      t.userstamps
    end
    add_foreign_key :brand_suppliers, :companies, column: :supplier_id
    add_index :brand_suppliers, [:supplier_id, :brand_id], unique: true
  end
end
