class CreateCustomerOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_orders do |t|
      t.decimal :total
      t.references :contact, foreign_key: true

      t.timestamps
    end
  end
end
