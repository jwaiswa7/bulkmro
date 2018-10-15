class AddAutoAttachToEmailMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :email_messages, :auto_attach, :boolean, default: false
  end
end
