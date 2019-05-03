class CreateCustomerProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_products do |t|
      t.references :product, foreign_key: true
      t.references :company, foreign_key: true
      t.references :category, foreign_key: true
      t.references :brand, foreign_key: true

      t.string :name
      t.string :sku

      t.decimal :customer_price

      t.timestamps
      t.userstamps
    end

    add_index :customer_products, [:company_id, :sku], unique: true
  end
end
