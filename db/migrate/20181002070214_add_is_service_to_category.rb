class AddIsServiceToCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :is_service, :boolean
  end
end
