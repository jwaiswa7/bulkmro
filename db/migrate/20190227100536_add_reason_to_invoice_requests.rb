class AddReasonToInvoiceRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :invoice_requests, :rejection_reason, :string
  end
end
