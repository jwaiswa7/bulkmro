class AddDeliveryChallanIdsToArInvoiceRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :ar_invoice_requests, :delivery_challan_ids, :jsonb
  end
end
