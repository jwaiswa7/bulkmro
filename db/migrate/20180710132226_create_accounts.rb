class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.string :name, index: { :unique => true }
      t.string :alias, index: { :unique => true }
      t.string :remote_uid, index: { :unique => true }

      t.timestamps
      t.userstamps
    end
  end
end
