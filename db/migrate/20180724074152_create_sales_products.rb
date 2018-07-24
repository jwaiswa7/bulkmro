class CreateSalesProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_products do |t|
      t.references :sales_quote, foreign_key: true
      t.references :product, foreign_key: true
      t.integer :supplier_id, index: true

      t.integer :quantity
      t.decimal :unit_cost_price, default: 0
      t.decimal :margin
      t.decimal :unit_sales_price, default: 0

      t.timestamps
      t.userstamps
    end

    add_index :sales_products, [:sales_quote_id, :product_id], unique: true
    add_foreign_key :sales_products, :companies, column: :supplier_id
  end
end
