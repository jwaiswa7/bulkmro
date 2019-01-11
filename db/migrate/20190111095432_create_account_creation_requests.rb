class CreateAccountCreationRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :account_creation_requests do |t|
      t.string :name
      t.string :account_type
      t.references :company_creation_request, foreign_key: true
      t.timestamps

    end
  end
end
