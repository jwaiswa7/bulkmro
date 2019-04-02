class AddCompanyAccountIdInEmailMessages < ActiveRecord::Migration[5.2]
  def change
    add_reference :email_messages,:account,foreign_key: true unless column_exists? :email_messages,:account_id
    add_reference :email_messages,:company,foreign_key: true unless column_exists? :email_messages,:company_id
  end
end
