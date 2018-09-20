class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.integer :remote_uid, index: true

      t.string :name, index: { :unique => true }
      t.string :alias

      t.timestamps
      t.userstamps
    end
  end
end
