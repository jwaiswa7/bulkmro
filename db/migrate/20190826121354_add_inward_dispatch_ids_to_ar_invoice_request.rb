class AddInwardDispatchIdsToArInvoiceRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :ar_invoice_requests, :inward_dispatch_ids, :jsonb
  end
end
