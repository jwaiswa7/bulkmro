class AddUidToEmailMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :email_messages, :uid, :string
  end
end
