class CreateSalesOrderRows < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_order_rows do |t|
      t.references :sales_order, foreign_key: true
      t.references :sales_quote_row, foreign_key: true

      t.decimal :quantity

      t.timestamps
      t.userstamps
    end

    add_index :sales_order_rows, [:sales_order_id, :sales_quote_row_id], unique: true
  end
end
