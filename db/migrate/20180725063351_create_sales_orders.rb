class CreateSalesOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_orders do |t|
      t.references :sales_approval, foreign_key: true

      t.text :comments

      t.timestamps
      t.userstamps
    end
  end
end
