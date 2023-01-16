class AddEmailableToEmailMessage < ActiveRecord::Migration[5.2]
  def change
    add_reference :email_messages, :emailable, index: true, polymorphic: true
  end
end
