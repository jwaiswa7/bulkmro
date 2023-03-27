class AddTagUserToTaskComment < ActiveRecord::Migration[5.2]
  def change
    add_column :task_comments, :tag_user_id, :integer
  end
end
