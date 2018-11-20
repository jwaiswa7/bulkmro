class AddIsVisibleFieldTables < ActiveRecord::Migration[5.2]
  def change
    add_column :products,:is_active,:boolean,:default => true
    add_column :brands,:is_active,:boolean,:default => true
    add_column :tax_codes,:is_active,:boolean,:default => true
    add_column :categories,:is_active,:boolean,:default => true
    add_column :companies,:is_active,:boolean,:default => true
    add_column :contacts,:is_active,:boolean,:default => true
  end
end
