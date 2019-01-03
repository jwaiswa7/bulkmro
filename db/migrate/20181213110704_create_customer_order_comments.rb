class CreateCustomerOrderComments < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_order_comments do |t|
      t.references :customer_order, foreign_key: true
      t.references :contact, foreign_key: true
      t.text :message

      t.userstamps
      t.timestamps
    end
  end
end
