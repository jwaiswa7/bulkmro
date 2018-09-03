class CreateSalesOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_orders do |t|
      t.references :sales_quote, foreign_key: true

      t.timestamps
    end
  end
end
