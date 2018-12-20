class AddColumnsWarehouse < ActiveRecord::Migration[5.2]
  def change
    add_column :warehouses,:is_active,:boolean,:default => true
  end
end
