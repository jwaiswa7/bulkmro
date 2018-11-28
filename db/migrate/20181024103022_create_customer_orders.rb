class CreateCustomerOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_orders do |t|
      t.references :contact, foreign_key: true

      t.decimal :total

      t.timestamps
    end
  end
end
