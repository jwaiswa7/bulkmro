class CreateCompanyContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :company_contacts do |t|
      t.references :company, foreign_key: true
      t.references :contact, foreign_key: true

      t.timestamps
      t.userstamps
    end

    add_index :company_contacts, [:company_id, :contact_id], unique: true
  end
end
