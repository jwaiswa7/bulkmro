class AddRemoveColumnsAnnualTargets < ActiveRecord::Migration[5.2]
  def up
    add_reference :annual_targets, :account, foreign_key: true, index: true
    add_column :annual_targets, :resource_id, :integer
    add_column :annual_targets, :resource_type, :integer

    rename_column :annual_targets, :company_target, :account_target

    add_index :annual_targets, [:resource_type, :resource_id]
  end

  def down
    remove_column :annual_targets, :invoice_target
    remove_column :annual_targets, :invoice_margin_target
    remove_column :annual_targets, :order_target
    remove_column :annual_targets, :order_margin_target
    remove_column :annual_targets, :new_client_target
  end
end
