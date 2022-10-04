class AddInquiryProductSkuToCustomerProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_products, :inquiry_product_sku, :string
  end
end
