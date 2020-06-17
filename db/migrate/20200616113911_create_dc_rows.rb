class CreateDcRows < ActiveRecord::Migration[5.2]
  def change
    create_table :dc_rows do |t|
      t.references :sales_order_row, foreign_key: true

      t.integer :quantity
      t.integer :product_id
    end
  end
end
