class CreateCompanyContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :company_contacts do |t|
      t.references :contact, foreign_key: true
      t.references :company, foreign_key: true
      t.integer :remote_uid, index: { :unique => true }

      t.jsonb :legacy_metadata
      t.timestamps
      t.userstamps
    end
    add_index :company_contacts, [:company_id, :contact_id], unique: true
  end
end
