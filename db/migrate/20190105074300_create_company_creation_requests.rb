class CreateCompanyCreationRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :company_creation_requests do |t|
      t.string :name
      t.string :first_name
      t.string :last_name
      t.string :email
      t.integer :account_type
      t.integer :company_id
      t.text :address
      t.references :activity, foreign_key: true

      t.userstamps
      t.timestamps
    end
  end
end
