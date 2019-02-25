class CreateCustomerProductTags < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_product_tags do |t|
      t.references :tag, foreign_key: true
      t.references :customer_product, foreign_key: true

      t.timestamps
      t.userstamps
    end
  end
end
