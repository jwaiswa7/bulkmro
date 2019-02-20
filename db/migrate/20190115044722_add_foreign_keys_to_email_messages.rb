class AddForeignKeysToEmailMessages < ActiveRecord::Migration[5.2]
  def change
    add_reference :email_messages, :purchase_order, foreign_key: true
    add_reference :email_messages, :sales_order, foreign_key: true
    add_reference :email_messages, :sales_invoice, foreign_key: true
  end
end
