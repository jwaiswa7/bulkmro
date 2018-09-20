class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.string :remote_uid
      t.string :name, index: { :unique => true }
      t.string :alias
      t.timestamps
      t.userstamps
    end
  end
end
