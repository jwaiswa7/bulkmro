class AddBillingShippingIdToInquiries < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiries, :billing_company_id, :integer, index: true
    add_column :inquiries, :shipping_company_id, :integer, index: true

    add_foreign_key :inquiries, :companies, column: :billing_company_id
    add_foreign_key :inquiries, :companies, column: :shipping_company_id
  end
end
