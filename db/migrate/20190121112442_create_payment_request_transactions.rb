class CreatePaymentRequestTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_request_transactions do |t|
      t.integer :payment_type
      t.string :utr_or_cheque_no
      t.decimal :amount_paid
      t.date :cheque_date
      t.references :payment_request, foreign_key: true

      t.userstamps
      t.timestamps
    end
  end
end
