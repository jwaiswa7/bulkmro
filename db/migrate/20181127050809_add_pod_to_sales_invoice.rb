class AddPodToSalesInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_invoices, :pod_date, :date
    add_column :sales_invoices, :pod_attachment, :string
  end
end
