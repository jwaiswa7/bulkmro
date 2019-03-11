class AddLogisticsOwnerToPurchaseOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :logistics_owner_id, :integer
  end
end
