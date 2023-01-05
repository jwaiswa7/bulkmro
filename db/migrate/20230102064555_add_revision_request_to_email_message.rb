class AddRevisionRequestToEmailMessage < ActiveRecord::Migration[5.2]
  def change
    add_reference :email_messages, :revision_request, foreign_key: true
  end
end
