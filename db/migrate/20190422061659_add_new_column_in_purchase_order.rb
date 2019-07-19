class AddNewColumnInPurchaseOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :is_partial, :boolean, :default => false
  end
end
