class AddCompanyReferencesToCarts < ActiveRecord::Migration[5.2]
  def change
    add_column :carts, :billing_company_id, :integer
    add_column :carts, :shipping_company_id, :integer
    add_foreign_key :carts, :companies, column: :billing_company_id
    add_foreign_key :carts, :companies, column: :shipping_company_id
  end
end
