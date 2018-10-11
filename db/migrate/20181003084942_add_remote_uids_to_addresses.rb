class AddRemoteUidsToAddresses < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :remote_uid1, :string, index: true
    add_column :addresses, :remote_uid2, :string, index: true
  end
end
