class CreateCustomerOrderRows < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_order_rows do |t|
      t.references :customer_order, foreign_key: true
      t.references :product, foreign_key: true
      t.decimal :quantity

      t.timestamps
    end

    add_index :customer_order_rows, [:customer_order_id, :product_id], unique: true
  end
end
