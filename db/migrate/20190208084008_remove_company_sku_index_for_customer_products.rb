class RemoveCompanySkuIndexForCustomerProducts < ActiveRecord::Migration[5.2]
  def change
    remove_index :customer_products, column: [:company_id, :sku]
  end
end
