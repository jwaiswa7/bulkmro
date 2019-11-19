class AddStatusToExports < ActiveRecord::Migration[5.2]
  def change
    add_column :exports, :status, :integer
  end
end
