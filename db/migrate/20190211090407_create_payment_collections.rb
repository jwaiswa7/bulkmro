class CreatePaymentCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_collections do |t|
        t.references :account
        t.decimal :amount_received_on_account_no_due
        t.decimal :amount_received_on_account_overdue
        t.decimal :amount_received_against_invoice_no_due
        t.decimal :amount_received_against_invoice_overdue
        t.decimal :total_amount_received_no_due
        t.decimal :total_amount_received_overdue
        t.decimal :amount_outstanding_no_due
        t.decimal :amount_outstanding_overdue
        t.timestamps
    end
  end
end
