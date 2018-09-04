class CreateInquiryProductSuppliers < ActiveRecord::Migration[5.2]
  def change
    create_table :inquiry_product_suppliers do |t|
      t.references :inquiry_product, foreign_key: true
      t.integer :supplier_id, index: true
      t.decimal :unit_cost_price

      t.timestamps
      t.userstamps
    end

    add_foreign_key :inquiry_product_suppliers, :companies, column: :supplier_id
    add_index :inquiry_product_suppliers, [:inquiry_product_id, :supplier_id], unique: true, name: 'index_ips_on_inquiry_product_id_and_supplier_id'
  end
end
