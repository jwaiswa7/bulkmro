class AddStatusUpdatedAtField < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :status_updated_at, :datetime
  end
end
