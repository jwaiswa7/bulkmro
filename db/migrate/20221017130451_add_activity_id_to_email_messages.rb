class AddActivityIdToEmailMessages < ActiveRecord::Migration[5.2]
  def change
    add_reference :email_messages,:activity, foreign_key: true unless column_exists? :email_messages,:activity_id
  end
end
