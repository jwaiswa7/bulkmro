class AddIssueDateToPaymentRequestTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_request_transactions, :issue_date, :date
  end
end
