class CreateSalesOrderConfirmations < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_order_confirmations do |t|
      t.references :sales_order, foreign_key: true

      t.timestamps
      t.userstamps
    end
  end
end
