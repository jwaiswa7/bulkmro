class AddCompanyRefToAddressesAndCompanyContacts < ActiveRecord::Migration[5.2]
  def change
    add_reference :addresses, :company, foreign_key: true
    add_reference :company_contacts, :company, foreign_key: true
  end
  add_index :company_contacts, [:company_id, :contact_id], unique: true
end
