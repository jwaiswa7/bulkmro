class CreatePaymentOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_options do |t|
      t.integer :remote_uid, index: {unique: true}
      t.integer :legacy_id, index: true

      t.string :name, index: { unique: true }

      t.decimal :credit_limit
      t.decimal :general_discount
      t.integer :load_limit

      t.jsonb :legacy_metadata
      t.timestamps
    end
  end
end
