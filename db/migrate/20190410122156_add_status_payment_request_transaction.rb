class AddStatusPaymentRequestTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_request_transactions, :status, :integer
  end
end
