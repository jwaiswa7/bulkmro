class AddDueDateTo < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :due_date, :datetime
  end
end
