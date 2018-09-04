class CreateSalesProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_products do |t|
      t.references :sales_quote, foreign_key: true
      t.references :inquiry_supplier, foreign_key: true

      t.integer :quantity
      t.decimal :margin_percentage
      t.decimal :unit_selling_price

      t.timestamps
      t.userstamps
    end

    add_index :sales_products, [:sales_quote_id, :inquiry_supplier_id], unique: true
  end
end
