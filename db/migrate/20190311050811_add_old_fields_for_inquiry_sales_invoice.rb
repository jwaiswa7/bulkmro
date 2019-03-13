class AddOldFieldsForInquirySalesInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiries, :old_inquiry_number, :string
    add_column :sales_orders, :old_order_number, :string
    add_column :sales_invoices, :old_invoice_number, :string
  end
end
