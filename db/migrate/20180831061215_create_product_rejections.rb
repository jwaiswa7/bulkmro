class CreateProductRejections < ActiveRecord::Migration[5.2]
  def change
    create_table :product_rejections do |t|
      t.references :product, foreign_key: true
      t.references :product_comment, foreign_key: true

      t.userstamps
      t.timestamps
    end
  end
end
