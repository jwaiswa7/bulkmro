class AddPoAndPaymentOptionReference < ActiveRecord::Migration[5.2]
  def change
    add_reference :po_requests, :purchase_order, foreign_key: true
    add_reference :purchase_orders, :payment_option, foreign_key: true
  end
end
