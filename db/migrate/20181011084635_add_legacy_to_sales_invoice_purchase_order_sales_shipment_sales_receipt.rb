class AddLegacyToSalesInvoicePurchaseOrderSalesShipmentSalesReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_invoices, :legacy_id, :integer, index: true
    add_column :sales_shipments, :legacy_id, :integer, index: true
    add_column :purchase_orders, :legacy_id, :integer, index: true
    add_column :sales_receipts, :legacy_id, :integer, index: true
    add_column :sales_invoices, :is_legacy, :boolean
    add_column :sales_shipments, :is_legacy, :boolean
    add_column :purchase_orders, :is_legacy, :boolean
    add_column :sales_receipts, :is_legacy, :boolean
  end
end
