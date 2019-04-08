class CreateMaterialReadinessFollowup < ActiveRecord::Migration[5.2]
  def change
    create_table :material_readiness_followups do |t|
      t.references :purchase_order, foreign_key: true
      t.references :overseer, foreign_key: true
      t.string :document_type
      t.timestamp :expected_dispatch_date
      t.timestamp :expected_delivery_date
      t.timestamp :actual_delivery_date
      t.integer :status, default: 10
      t.integer :type_of_doc
      t.integer :logistics_owner_id

      t.userstamps
      t.timestamps
    end
  end
end
