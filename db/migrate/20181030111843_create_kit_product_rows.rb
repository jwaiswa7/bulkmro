class CreateKitProductRows < ActiveRecord::Migration[5.2]
  def change
    create_table :kit_product_rows do |t|
      t.decimal :quantity
      t.references :product, foreign_key: true
      t.references :kit, foreign_key: true

      t.timestamps
    end
  end
end
