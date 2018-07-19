class CreateInquiryProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :inquiry_products do |t|
      t.references :inquiry, foreign_key: true
      t.references :product, foreign_key: true

      t.integer :quantity

      t.timestamps
      t.userstamps
    end

    add_index :inquiry_products, [:inquiry_id, :product_id], unique: true
  end
end
