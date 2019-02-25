class RenameInternalStatusToMaterialStatus < ActiveRecord::Migration[5.2]
  def change
    rename_column :purchase_orders, :internal_status, :material_status
  end
end
