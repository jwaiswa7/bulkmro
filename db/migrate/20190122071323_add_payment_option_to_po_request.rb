class AddPaymentOptionToPoRequest < ActiveRecord::Migration[5.2]
  def change
    add_reference :po_requests, :payment_option, foreign_key: true
  end
end
