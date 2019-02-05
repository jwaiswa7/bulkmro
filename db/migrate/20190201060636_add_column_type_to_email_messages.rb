class AddColumnTypeToEmailMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :email_messages, :email_type, :integer
  end
end
