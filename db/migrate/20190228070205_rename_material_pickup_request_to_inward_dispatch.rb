class RenameMaterialPickupRequestToInwardDispatch < ActiveRecord::Migration[5.2]
  def change
    remove_index :mpr_rows, name: 'index_mprr_on_mpr_and_por'
    rename_table :material_pickup_requests, :inward_dispatches

    rename_table :mpr_rows, :inward_dispatch_rows
    rename_column :inward_dispatch_rows, :material_pickup_request_id, :inward_dispatch_id
    add_index :inward_dispatch_rows, [:inward_dispatch_id, :purchase_order_row_id], unique: true, name: 'index_idr_on_id_and_por'

    rename_table :mpr_comments, :inward_dispatch_comments
    rename_column :inward_dispatch_comments, :material_pickup_request_id, :inward_dispatch_id
  end
end
