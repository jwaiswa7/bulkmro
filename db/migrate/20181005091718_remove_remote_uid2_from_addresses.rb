class RemoveRemoteUid2FromAddresses < ActiveRecord::Migration[5.2]
  def change
    remove_column :addresses, :remote_uid2, :string
  end
end
