class AddPurposeOfPaymentToPaymentRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_requests, :purpose_of_payment, :integer
  end
end
