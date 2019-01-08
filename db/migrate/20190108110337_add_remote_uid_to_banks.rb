class AddRemoteUidToBanks < ActiveRecord::Migration[5.2]
  def change
    add_column :banks, :remote_uid, :integer
  end
end
