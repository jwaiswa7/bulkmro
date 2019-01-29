class AddCcrColumnToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :company_creation_request_id, :integer
  end
end
