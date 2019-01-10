class AddLogisticsOwnerToPoRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :po_requests, :logistics_owner_id, :integer, index: true

    add_foreign_key :po_requests, :overseers, column: :logistics_owner_id
  end
end
