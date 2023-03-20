class CreateCreateTaskComments < ActiveRecord::Migration[5.2]
  def change
    create_table :create_task_comments do |t|
      t.integer :task_id
      t.text :message

      t.timestamps
      t.userstamps
    end
  end
end
