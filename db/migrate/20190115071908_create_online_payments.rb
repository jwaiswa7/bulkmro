class CreateOnlinePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :online_payments do |t|
      t.references :customer_order
      t.references :contact

      t.string :payment_id
      t.string :auth_token

      t.decimal :amount
      t.decimal :captured_amount

      t.integer :cart_id
      t.integer :status
      t.jsonb :metadata

      t.timestamps
      t.userstamps
    end
  end
end
