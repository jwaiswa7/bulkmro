class CompanyContactIndex < ActiveRecord::Migration[5.2]
  def up
    add_index :company_contacts, [:company_id, :contact_id], unique: false
  end

  def down 
    remove_index :company_contacts, [:company_id, :contact_id]
  end
end
