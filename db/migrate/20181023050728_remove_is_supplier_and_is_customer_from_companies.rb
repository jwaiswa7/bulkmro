class RemoveIsSupplierAndIsCustomerFromCompanies < ActiveRecord::Migration[5.2]
  def change
    remove_column :companies, :is_supplier, :boolean
    remove_column :companies, :is_customer, :boolean
  end
end
