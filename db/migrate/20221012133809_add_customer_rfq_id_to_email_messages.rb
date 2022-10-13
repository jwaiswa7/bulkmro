class AddCustomerRfqIdToEmailMessages < ActiveRecord::Migration[5.2]
  def change
    add_reference :email_messages,:customer_rfq, foreign_key: true unless column_exists? :email_messages,:customer_rfq_id
  end
end
