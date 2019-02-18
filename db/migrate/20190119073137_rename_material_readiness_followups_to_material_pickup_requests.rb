class RenameMaterialReadinessFollowupsToMaterialPickupRequests < ActiveRecord::Migration[5.2]

  def change
    remove_index :mrf_rows, name: 'index_mrfr_on_mrf_and_por'
    rename_table :material_readiness_followups, :material_pickup_requests

    rename_table :mrf_rows, :mpr_rows
    rename_column :mpr_rows, :material_readiness_followup_id, :material_pickup_request_id
    add_index :mpr_rows, [:material_pickup_request_id, :purchase_order_row_id], unique: true, name: 'index_mprr_on_mpr_and_por'

    rename_table :mrf_comments, :mpr_comments
    rename_column :mpr_comments, :material_readiness_followup_id, :material_pickup_request_id
  end
end