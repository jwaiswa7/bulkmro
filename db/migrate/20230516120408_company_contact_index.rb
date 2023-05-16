class CompanyContactIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :company_contacts, [:company_id, :contact_id]
    add_index :company_contacts, [:company_id, :contact_id], unique: false
  end
end
