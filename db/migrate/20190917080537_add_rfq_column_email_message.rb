class AddRfqColumnEmailMessage < ActiveRecord::Migration[5.2]
  def change
    add_reference :email_messages,:supplier_rfq, foreign_key: true unless column_exists? :email_messages,:supplier_rfq_id
  end
end
