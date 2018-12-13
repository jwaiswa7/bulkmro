class AddPaymentOptionRefToPurchaseOrder < ActiveRecord::Migration[5.2]
  def change
    add_reference :purchase_orders, :payment_option
  end
end
