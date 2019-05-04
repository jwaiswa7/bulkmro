class AddDueDateToPaymentRequestTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_request_transactions, :transaction_due_date, :date
  end
end
