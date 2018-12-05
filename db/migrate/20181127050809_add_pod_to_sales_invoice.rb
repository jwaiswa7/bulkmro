class AddPodToSalesInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_invoices, :delivery_date, :date
    add_column :sales_invoices, :pod_attachment, :string
  end
end
