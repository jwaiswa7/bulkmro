class CreateInquirySuppliers < ActiveRecord::Migration[5.2]
  def change
    create_table :inquiry_suppliers do |t|
      t.references :inquiry_product, foreign_key: true
      t.integer :supplier_id, index: true

      t.timestamps
      t.userstamps
    end
    add_foreign_key :inquiry_suppliers, :companies, column: :supplier_id
    add_index :inquiry_suppliers, [:inquiry_product_id, :supplier_id], unique: true
  end
end
