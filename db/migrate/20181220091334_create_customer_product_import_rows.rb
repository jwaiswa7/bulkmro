class CreateCustomerProductImportRows < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_product_import_rows do |t|
      t.references :customer_product_import, foreign_key: true, index: { name: 'index_customer_product_import' }
      t.references :customer_product, foreign_key: true, on_delete: :nullify

      t.string :sku
      t.jsonb :metadata

      t.timestamps
    end
  end
end
