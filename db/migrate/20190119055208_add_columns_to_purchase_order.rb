class AddColumnsToPurchaseOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :supplier_dispatch_date, :timestamp
    add_column :purchase_orders, :revised_supplier_delivery_date, :timestamp
  end
end
