class AddCompanyContactFkToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :companies, :company_contacts, column: :default_contact_id
  end
end
