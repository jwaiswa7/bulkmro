class CreatePoRequestProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :po_request_products do |t|
      t.references :po_request, foreign_key: true
      t.references :sales_order_row, foreign_key: true
      t.integer :quantity
      t.references :sales_quote_row, foreign_key: true
      t.references :product, foreign_key: true

      t.timestamps
    end
  end
end
