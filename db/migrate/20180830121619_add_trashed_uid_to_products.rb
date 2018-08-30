class AddTrashedUidToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :trashed_uid, :string, index: true
  end
end
