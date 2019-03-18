class AddOldPoNumberToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :old_po_number, :string
  end
end
