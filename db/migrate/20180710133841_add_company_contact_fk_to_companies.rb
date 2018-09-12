class AddCompanyContactFkToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :companies, :company_contacts, column: :default_company_contact_id
  end
end
