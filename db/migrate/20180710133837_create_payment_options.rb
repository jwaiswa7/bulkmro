class CreatePaymentOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_options do |t|
      t.string :name
      t.integer :remote_uid
      t.timestamps
    end
  end
end
