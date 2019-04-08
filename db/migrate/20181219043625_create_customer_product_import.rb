class CreateCustomerProductImport < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_product_imports do |t|
      t.references :company, foreign_key: true
      t.integer :import_type, index: true
      t.text :import_text

      t.timestamps
      t.userstamps
    end
  end
end
