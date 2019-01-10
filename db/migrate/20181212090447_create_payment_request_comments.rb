class CreatePaymentRequestComments < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_request_comments do |t|
      t.references :payment_request, foreign_key: true
      t.text :message

      t.userstamps
      t.timestamps
    end
  end
end
