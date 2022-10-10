class CreateCustomerRfqs < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_rfqs do |t|
      t.references :inquiry, foreign_key: true
      t.integer :account_id
      t.string :subject

      t.timestamps
      t.userstamps
    end
  end
end
