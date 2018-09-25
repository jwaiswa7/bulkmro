class CreateGmailSmtps < ActiveRecord::Migration[5.2]
  def change
    create_table :gmail_smtps do |t|
      t.string :email, index: { :unique => true }
      t.string :password

      t.timestamps
    end
  end
end
