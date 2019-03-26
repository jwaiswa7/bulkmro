class CreateContactCreationRequest < ActiveRecord::Migration[5.2]
  def change
    create_table :contact_creation_requests do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number
      t.string :mobile_number
      t.integer :contact_id
      t.references :activity, foreign_key: true
      t.references :company_creation_request, foreign_key: true
      t.userstamps
      t.timestamps
    end
  end
end
