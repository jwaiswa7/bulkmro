class AddFewFieldsToCustomerProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_products, :technical_description, :text
    add_column :customer_products, :customer_product_sku, :string
    add_column :customer_products, :lead_time, :string
    add_column :customer_products, :customer_uom, :string
  end
end
