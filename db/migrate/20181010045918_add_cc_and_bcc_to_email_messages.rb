class AddCcAndBccToEmailMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :email_messages, :cc, :string, array: true
    add_column :email_messages, :bcc, :string, array: true
  end
end
