class AddStatusToPurchaseOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :status, :integer, index: true
  end
end
