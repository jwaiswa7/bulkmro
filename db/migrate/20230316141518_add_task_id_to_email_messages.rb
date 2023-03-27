class AddTaskIdToEmailMessages < ActiveRecord::Migration[5.2]
  def change
    add_reference :email_messages,:task, foreign_key: true unless column_exists? :email_messages,:task_id
  end
end
