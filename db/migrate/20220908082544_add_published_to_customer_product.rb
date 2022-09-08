class AddPublishedToCustomerProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_products, :published, :boolean, default: false
  end
end
