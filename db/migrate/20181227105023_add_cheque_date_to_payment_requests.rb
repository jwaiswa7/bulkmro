class AddChequeDateToPaymentRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_requests, :cheque_date, :date
  end
end
