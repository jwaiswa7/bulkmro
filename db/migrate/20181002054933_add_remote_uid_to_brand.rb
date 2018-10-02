class AddRemoteUidToBrand < ActiveRecord::Migration[5.2]
  def change
    add_column :brands, :remote_uid, :integer
  end
end
