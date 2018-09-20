class CreateProductComments < ActiveRecord::Migration[5.2]
  def change
    create_table :product_comments do |t|
      t.references :product, foreign_key: true

      t.string :merged_product_name
      t.string :merged_product_sku
      t.jsonb :merged_product_metadata

      t.text :message

      t.userstamps
      t.timestamps
    end
  end
end
