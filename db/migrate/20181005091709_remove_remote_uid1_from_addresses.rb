class RemoveRemoteUid1FromAddresses < ActiveRecord::Migration[5.2]
  def change
    remove_column :addresses, :remote_uid1, :string
  end
end
