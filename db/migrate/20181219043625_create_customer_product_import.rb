class CreateCustomerProductImport < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_product_imports do |t|
      t.references :company
      t.integer :import_type
      t.text :import_text
      t.timestamps
      t.userstamps
    end
  end
end
