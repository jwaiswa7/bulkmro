class AddTransportModeColumnInPurchaseOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :transport_mode, :integer
    add_column :po_requests, :transport_mode,:integer
    add_column :purchase_orders, :delivery_type, :integer
    add_column :po_requests, :delivery_type, :integer
  end
end
