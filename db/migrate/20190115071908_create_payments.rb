class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.references :customer_order
      t.references :contact
      t.jsonb :metadata
      t.decimal :amount
      t.integer :status

      t.timestamps
      t.userstamps
    end
  end
end
