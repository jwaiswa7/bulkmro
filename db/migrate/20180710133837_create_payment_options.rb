class CreatePaymentOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_options do |t|

      t.integer :remote_uid, index: {unique: true}
      t.integer :legacy_id, index: true

      t.jsonb :legacy_metadata

      t.string :name
      t.timestamps
    end
  end
end
