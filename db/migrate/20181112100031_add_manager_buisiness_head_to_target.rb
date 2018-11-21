class AddManagerBuisinessHeadToTarget < ActiveRecord::Migration[5.2]
  def change
    add_column :targets, :manager_id, :integer, index: true
    add_column :targets, :business_head_id, :integer, index: true

    add_foreign_key :targets, :overseers, column: :manager_id
    add_foreign_key :targets, :overseers, column: :business_head_id
  end
end
