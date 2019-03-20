class RemoveCreatedByFromProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :created_by
  end
end
