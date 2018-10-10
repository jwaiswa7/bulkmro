class AddRemoteUidToAddresses < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :remote_uid, :string
  end
end
