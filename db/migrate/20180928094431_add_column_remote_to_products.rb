class AddColumnRemoteToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :remote_uid, :string
  end
end
