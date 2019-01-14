class CreateCompanyCreationRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :company_creation_requests do |t|
      t.string :name
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :account_name
      t.integer :account_type
      t.text :address
      t.references :activity, foreign_key: true
      t.references :account, foreign_key: true
      t.timestamps
    end
  end
end
