class AddCompanyToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_reference :purchase_orders, :company, foreign_key: true
    add_reference :purchase_order_rows, :product, foreign_key: true
  end
end
