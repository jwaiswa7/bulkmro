class CreateSalesOrderComments < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_order_comments do |t|
      t.references :sales_order, foreign_key: true
      t.text :message

      t.userstamps
      t.timestamps
    end
  end
end
