class AddColumnActivityDateToActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :activity_date, :datetime
  end
end
