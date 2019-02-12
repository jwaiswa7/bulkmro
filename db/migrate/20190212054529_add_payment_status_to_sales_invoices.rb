class AddPaymentStatusToSalesInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_invoices, :payment_status, :integer, :default => 10

  end
end
