class AddRemoteUidToBanks < ActiveRecord::Migration[5.2]
  def change
    add_column :banks, :remote_uid, :integer
    add_column :company_banks, :remote_uid, :integer
  end
end
