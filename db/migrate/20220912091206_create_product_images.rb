class CreateProductImages < ActiveRecord::Migration[5.2]
  def change
    create_table :product_images do |t|
      t.string :sku
      t.string :image

      t.timestamps
    end
  end
end
