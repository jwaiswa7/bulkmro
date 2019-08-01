class AddRemoteuidFieldInPo < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :remote_uid, :integer, unique: true
  end
end
