class RemoveLogisticsOwnerFromPoRequest < ActiveRecord::Migration[5.2]
  def change
    remove_column :po_requests, :logistics_owner_id, :integer, index: true

    remove_foreign_key :po_requests, :overseers
  end
end
