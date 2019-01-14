class AddColumnsToMaterialReadinessFollowup < ActiveRecord::Migration[5.2]
  def change
    add_column :material_readiness_followups, :expected_dispatch_date, :date
    add_column :material_readiness_followups, :expected_delivery_date, :date
    add_column :material_readiness_followups, :actual_delivery_date, :date
    add_column :material_readiness_followups, :status, :integer, default: 10
    add_column :material_readiness_followups, :type_of_doc, :integer
    add_column :material_readiness_followups, :logistics_owner_id, :integer

    add_index :material_readiness_followups, :logistics_owner_id
  end
end
