class AddCompanyAccountIdInEmailMessages < ActiveRecord::Migration[5.2]
  def change
    add_reference :email_messages, :account, foreign_key: true
    add_reference :email_messages, :company, foreign_key: true
  end
end
