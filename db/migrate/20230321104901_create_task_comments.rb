class CreateTaskComments < ActiveRecord::Migration[5.2]
  def change
    create_table :task_comments do |t|
      t.references :task, foreign_key: true
      t.text :message

      t.timestamps
      t.userstamps
    end
  end
end
