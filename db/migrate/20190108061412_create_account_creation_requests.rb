class CreateAccountCreationRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :account_creation_requests do |t|
      t.string :name
      t.integer :account_type
      t.timestamps
    end
  end
end
