class AddCcrColumnToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :reference_company_creation_request_id, :integer
  end
end
