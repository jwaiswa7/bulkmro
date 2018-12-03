class AddMoqAndPriceToCustomerProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_products, :moq, :integer
    add_column :customer_products, :unit_selling_price, :decimal
  end
end
