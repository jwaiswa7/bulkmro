class CreatePaymentRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_requests do |t|
      t.references :inquiry, foreign_key: true
      t.references :purchase_order, foreign_key: true
      t.references :po_request, foreign_key: true

      t.integer :status
      t.integer :utr_number
      t.date :due_date

      t.string :attachments

      t.userstamps
      t.timestamps
    end
  end
end
