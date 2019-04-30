class AddDueDateToPaymentRequestTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_request_transactions, :due_date, :date
  end
end
