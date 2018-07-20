class CreateCategorySuppliers < ActiveRecord::Migration[5.2]
  def change
    create_table :category_suppliers do |t|
      t.references :category, foreign_key: true
      t.integer :supplier_id, index: true

      t.timestamps
      t.userstamps
    end
    add_foreign_key :category_suppliers, :companies, column: :supplier_id
    add_index :category_suppliers, [:supplier_id, :category_id], unique: true
  end
end
