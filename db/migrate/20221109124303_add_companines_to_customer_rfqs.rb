class AddCompaninesToCustomerRfqs < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_rfqs, :billing_company_id, :integer
    add_column :customer_rfqs, :shipping_company_id, :integer
  end
end
