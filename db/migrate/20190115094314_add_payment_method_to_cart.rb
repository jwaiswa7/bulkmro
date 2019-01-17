class AddPaymentMethodToCart < ActiveRecord::Migration[5.2]
  def change
    add_column :carts, :payment_method, :integer
    add_column :customer_orders, :payment_method, :integer
    add_column :carts, :metadata, :jsonb
  end
end
