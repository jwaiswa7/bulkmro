class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.integer :remote_uid, index: true
      t.integer :legacy_id, index: true

      t.string :name, index: { :unique => true }
      t.string :alias

      t.integer :account_type

      t.jsonb :legacy_metadata
      t.timestamps
      t.userstamps
    end
  end
end
