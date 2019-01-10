class CreateWarehouseProductStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :warehouse_product_stocks do |t|
      t.references :warehouse, foreign_key: true
      t.references :product, foreign_key: true
      t.decimal :instock
      t.decimal :committed
      t.decimal :ordered

      t.timestamps
    end
  end
end
