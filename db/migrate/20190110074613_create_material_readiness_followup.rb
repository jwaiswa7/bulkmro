class CreateMaterialReadinessFollowup < ActiveRecord::Migration[5.2]
  def change
    create_table :material_readiness_followups do |t|
      t.references :purchase_order, foreign_key: true
      t.references :overseer, foreign_key: true
      t.string :document_type

      t.userstamps
      t.timestamps
    end
  end
end
