class AddNewColumnsToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :is_customer, :boolean, default: true
    add_column :companies, :is_supplier, :boolean, default: false
  end
end
