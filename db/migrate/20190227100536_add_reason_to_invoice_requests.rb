class AddReasonToInvoiceRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :invoice_requests, :rejection_reason, :integer
    add_column :invoice_requests, :other_rejection_reason, :string
    add_column :invoice_requests, :cancellation_reason, :string
  end
end
